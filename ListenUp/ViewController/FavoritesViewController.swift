//
//  FavoritesViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import Parse
import ProgressHUD
import UIKit

class FavoritesViewController: ParentPostList {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favorites"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
        
        if let user = User.current() {
            if let postsFav: [Post] = user.object(forKey: "favoritedPosts") as? [Post] {
                postsFav.forEach { post in
                    do {
                        try post.fetchIfNeeded()
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                posts = postsFav.reversed()
                guard posts.count > 0 else {
                    ProgressHUD.dismiss()
                    return
                }
                print(posts.map({ post in
                    return post.trackName
                }))
                ProgressHUD.dismiss()
                tableView.reloadData()
            }
            else {
                ProgressHUD.dismiss()
            }
        }
        else {
            ProgressHUD.dismiss()
            print("User is not signed in... can't make posts.")
            let ac = UIAlertController(title: "Not Signed In", message: "You must sign in to see your favorites.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        
    }

    
    
    override func viewDidDisappear(_ animated: Bool) {
        whatsPlaying?.enterPausedState()
    }

}
