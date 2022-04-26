//
//  FavoritesViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import Parse
import UIKit

class FavoritesViewController: ParentPostList {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favorites"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        if let user = User.current() {
            if let postsFav: [Post] = user.object(forKey: "favoritedPosts") as? [Post] {
                
                posts = sortPosts(arr: postsFav)
                print(posts.map({ post in
                    return post.trackName
                }))
                tableView.reloadData()
            }
        }
        else {
            print("User is not signed in... can't make posts.")
            let ac = UIAlertController(title: "Not Signed In", message: "You must sign in to see your favorites.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        
    }

    //
    // A demonstration of how to override a template function
    //
    // If you need to add functionality, just copy the func declaration verbatim with override in front. Then, call super.functionName(params: params) at some point. Put the extra functionality in wherever you need it.
    override func heartPost(post: Post, cell: PostTableViewCell) -> Bool {
        let hearted = super.heartPost(post: post, cell: cell)
        // Do any extra actions here
        return hearted
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        whatsPlaying?.enterPausedState()
    }

}
