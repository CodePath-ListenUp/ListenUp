//
//  FavoritesViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import Parse
import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts: [Post] = []
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favorites"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        if let user = User.current() {
            if let postsFav: [Post] = user.object(forKey: "favoritedPosts") as? [Post] {
                
                posts = sortPosts(arr: postsFav)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        return cell
    }


}
