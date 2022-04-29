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
                
                func fetchIt(index: Int, completion: @escaping () -> ()) {
                    postsFav[index].fetchIfNeededInBackground { post, error in
                        if index+1 < postsFav.count {
                            fetchIt(index: index+1) {
                                completion()
                            }
                        }
                        else { completion() }
                    }
                }
                
                fetchIt(index: 0) {
                    self.posts = postsFav.reversed()
                    guard self.posts.count > 0 else {
                        ProgressHUD.dismiss()
                        return
                    }
                    ProgressHUD.dismiss()
                    self.tableView.reloadData()
                }
                
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

    override func viewWillAppear(_ animated: Bool) {
        // These actions will occur every time the user switches back to the screen (via the tab bar for example)
        viewDidLoad()
    }
}
