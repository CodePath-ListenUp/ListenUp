//
//  PostViewController.swift
//  ListenUp
//
//  Created by Harshad Barapatre on 4/18/22.
//

import UIKit

class NewPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [SongResult] = []
    var searchQuery = String()
    
    var returningViewController: FeedViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        tableView.allowsSelection = false
        
        searchBar.becomeFirstResponder()
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
        
        return cell
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
                        print("post not set for tappedCell")
                        return
                    }
                    
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

}
   
