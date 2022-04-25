//
//  PostViewController.swift
//  ListenUp
//
//  Created by Harshad Barapatre on 4/18/22.
//

import UIKit
import AVFAudio
import Parse
import UIKit
import ProgressHUD

class NewPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [SongResult] = []
    var searchQuery = String()
    var whatsPlaying: ResultTableViewCell? = nil
    
    var returningViewController: FeedViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post"
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.allowsSelection = false
        
        searchBar.becomeFirstResponder()
        
//        tableView.separatorColor = UIColor.clear
    }
    
    // Temporary block of code for context menu
    // Context Menu items received from ShareContextMenu.swift
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil,
                                              actionProvider: { suggestedActions in
            
            return UIMenu(title: "", children: getContextMenuChildren(self, self.searchResults[indexPath.row]))
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell") as? ResultTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        var result: SongResult?
        if indexPath.row >= searchResults.count {
            cell.postSymbol.isUserInteractionEnabled = false
            result = nil
        }
        else {
            result = searchResults[indexPath.row]
            cell.result = result!
            cell.postSymbol.isUserInteractionEnabled = true
        }
        
        guard let fineResult = result else {
            return cell
        }
        
        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        cell.trackNameLabel?.text = fineResult.trackName
        cell.artistNameLabel?.text = fineResult.artistName

        guard let albumArtworkURL = URL(string: fineResult.artworkUrl100) else {
            return cell
        }

        cell.albumArtworkView?.load(url: albumArtworkURL)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTriedToPostSong(_:)))
        tapGesture.numberOfTapsRequired = 1
        cell.postSymbol.addGestureRecognizer(tapGesture)
        
        // Source: https://stackoverflow.com/a/35019685
        cell.darkeningLayer.frame = cell.albumArtworkView.bounds;
        cell.darkeningLayer.backgroundColor = UIColor.black.cgColor
        cell.darkeningLayer.opacity = nonPlayingArtworkOpacity
        cell.albumArtworkView.layer.addSublayer(cell.darkeningLayer)
        
        //
        // MARK: Media Button Work
        //
        
        // To identify which cell's button got called, we can use tag to pass the indexPath row
        cell.mediaButton.tag = indexPath.row
        
        cell.mediaButton.layer.shadowRadius = 10
        cell.mediaButton.layer.shadowOpacity = 0.8
        
        // To prevent having two Storyboard connections, I'm using the outlet to make an action
        cell.mediaButton.addTarget(self, action: #selector(userPressedMediaButton), for: .touchUpInside)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 92, bottom: 0, right: 0)
        
        return cell
    }
    
    @objc func userPressedMediaButton(_ sender: UIButton) {
        let post = searchResults[sender.tag]
        guard let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ResultTableViewCell else {
            print("Could not find post cell with given indexPath")
            return
        }
        
        if let oldPlay = whatsPlaying {
            // The user was already playing something, we need to turn that off first
            whatsPlaying?.enterPausedState()
            whatsPlaying = nil
            
            // Also, check that the one we're turning off isn't the user trying to turn it off themselves
            // Otherwise, we must return early
            if oldPlay == cell {
                return
            }
        }
        
        // Now that nothing is playing, let's play the next song
        // (we've already handled the case where the user stops a song above)
        cell.isPlaying = true
        whatsPlaying = cell
        cell.mediaButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        cell.darkeningLayer.opacity = playingArtworkOpacity
        cell.player.initPlayer(url: post.previewUrl) {
            cell.enterPausedState()
        }
        cell.player.play()
    }
    
    func getSearchResults(_ searchQuery: String) {
        retrieveITUNESResults(rawSearchTerm: searchQuery) { results in
            self.searchResults = results
            // Can't run UI code on background thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getSearchResults(searchText)
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    
    @objc func userTriedToPostSong(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? ResultTableViewCell {
                    guard let result = tappedCell.result else {
                        ProgressHUD.showFailed()
                        print("post not set for tappedCell")
                        return
                    }
                    
                    ProgressHUD.animationType = .lineScaling
                    ProgressHUD.colorAnimation = accentColor
                    ProgressHUD.show("POSTING")
                    
                    // Do Post processing here (pun intended)
                    let _ = Post(song: result, createdBy: User.current()!) { postReady in
                        postReady.saveInBackground { success, error in
                            guard success else {
                                print("An error occurred when posting the user's chosen song...")
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                else {
                                    print("No further details could be found.")
                                }
                                return
                            }
                        }
                        
                        DispatchQueue.main.async {
                            if let parent = self.returningViewController {
                                parent.posts.insert(postReady,at: 0)
                                parent.tableView.reloadData()
                            }
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        whatsPlaying?.enterPausedState()
        ProgressHUD.dismiss()
    }
}
