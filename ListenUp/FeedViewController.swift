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
    
    var posts: [SongResult] = []
    
    override func viewDidLoad() {
        navigationItem.title = "Feed"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
        
        retrieveITUNESResults(rawSearchTerm: "Dimension Altar") { results in
            self.posts = results
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
        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        cell.trackNameLabel?.text = post.trackName
        cell.artistNameLabel?.text = post.artistName
        
//        guard let albumArtworkData = post.artworkImageData else {
//            return cell
//        }
//
//        cell.albumArtworkView.image = UIImage(data: albumArtworkData)

        
        guard let albumArtworkURL = URL(string: post.artworkUrl100) else {
            return cell
        }
        
        cell.albumArtworkView?.load(url: albumArtworkURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("user tried to open song: \((tableView.cellForRow(at: indexPath) as! PostTableViewCell).trackNameLabel!.text)")
        
        let post = posts[indexPath.row]
        
        getSongwhipFromLink(linkString: post.trackViewUrl) { result in
            let url = URL(string: result.url)!
            let svc = SFSafariViewController(url: url)
            DispatchQueue.main.async {
                self.present(svc, animated: true)
            }
            
        }
        
        
    }
    
    @objc func addPost() {
        print("user did press add button")
    }
}



