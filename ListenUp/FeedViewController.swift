//
//  FeedViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import SafariServices
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        navigationItem.title = "Feed"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        let logoutButton = UIBarButtonItem(title: "TempLogOut", style: .plain, target: self, action: #selector(userLoggedOut))
        logoutButton.tintColor = UIColor.systemRed
        navigationItem.leftBarButtonItems = [
            logoutButton
        ]
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
        
        retrieveITUNESResults(rawSearchTerm: "Arkells") { results in
            self.posts = results.map({ result in
                return Post(song: result, createdBy: User.current()!) { post in
                    post.id = 5
                    post.saveInBackground { success, error in
                        if success {
                            print("ayo")
                        }
                        else {
                            print(error?.localizedDescription)
                            print(post.id)
                        }
                    }
                }
            })
            // Can't run UI code on background thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        let post = posts[indexPath.row]
        cell.post = post
        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        cell.trackNameLabel?.text = post.trackName
        cell.artistNameLabel?.text = post.artistName
        
        // Just another implementation for the images that we probably won't use
//        guard let albumArtworkData = post.artworkImageData else {
//            return cell
//        }
//
//        cell.albumArtworkView.image = UIImage(data: albumArtworkData)

        //MARK: Tags for Right-hand controls
        // upvote: 5
        // heart: 6
        // downvote: 7
        //
        // Have to create a unique tapGesture for each element,
        // so I'm using a for loop to expedite that / make it unified
        for view in [cell.upvoteSymbol,cell.heartIcon,cell.downvoteSymbol] {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapElement(_:)))
            tapGesture.numberOfTapsRequired = 1
            view?.addGestureRecognizer(tapGesture)
        }
        
        guard let albumArtworkURL = URL(string: post.artworkUrl100) else {
            return cell
        }
        
        cell.albumArtworkView?.load(url: albumArtworkURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell, let post = cell.post else {
            print("No post could be found for the swiped cell")
            return nil
        }
        
        let downvote = UIContextualAction(style: .normal, title: "Downvote") { action, view, completionHandler in
            self.downvotePost(post: post)
            completionHandler(true)
        }
        downvote.image = UIImage(systemName: "chevron.down")
        downvote.backgroundColor = .systemIndigo
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [downvote])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell, let post = cell.post else {
            print("No post could be found for the swiped cell")
            return nil
        }
        let upvote = UIContextualAction(style: .normal, title: "Upvote") { action, view, completionHandler in
            self.upvotePost(post: post)
            completionHandler(true)
        }
        upvote.image = UIImage(systemName: "chevron.up")
        upvote.backgroundColor = .systemOrange
        let swipeActions: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [upvote])
        return swipeActions
    }
    
    @objc func userDidTapElement(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let tapLocation = sender.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? PostTableViewCell {
                    guard let post = tappedCell.post else {
                        print("post not set for tappedCell")
                        return
                    }
                    
                    switch sender.view?.tag ?? 0 {
                    case 5:
                        upvotePost(post: post)
                    case 6:
                        heartPost(post: post)
                    case 7:
                        downvotePost(post: post)
                    default:
                        print("No action set in userDidTapElement for tag \(sender.view?.tag ?? 0)")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        
        if let songwhipStr = post.songLinkString, let url = URL(string: songwhipStr) {
            let svc = SFSafariViewController(url: url)
            DispatchQueue.main.async {
                self.present(svc, animated: true)
            }
        }
        else {
            getSongwhipFromLink(linkString: post.trackViewUrl) { result in
                self.posts[indexPath.row].songLinkString = result.url
                let url = URL(string: result.url)!
                let svc = SFSafariViewController(url: url)
                DispatchQueue.main.async {
                    self.present(svc, animated: true)
                }
            }
        }
    }
    
    @objc func addPost() {
        print("user did press add button")
        
        if let newScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as? NewPostViewController {self.present(newScreen, animated: true, completion: nil)}
    }
    
    @objc func userLoggedOut() {
        User.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    func upvotePost(post: Post) {
        print("user upvoted \(post.trackName)")
    }
    func heartPost(post: Post) {
        print("user favorited \(post.trackName)")
    }
    func downvotePost(post: Post) {
        print("user downvoted \(post.trackName)")
    }
}



