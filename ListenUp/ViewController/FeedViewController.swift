//
//  FeedViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import Parse
import ProgressHUD
import SafariServices
import UIKit
import AVFAudio

let nonPlayingArtworkOpacity: Float = 0.4
let playingArtworkOpacity: Float = 0.0

class FeedViewController: ParentPostList {
    
//    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Feed"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
        
        posts = []
        whatsPlaying = nil
        
        ProgressHUD.animationType = .lineScaling
        ProgressHUD.show()
        
        generatePostsForFeed { generatedPosts in
            self.posts = generatedPosts
            ProgressHUD.dismiss()
            self.tableView.reloadData()
        }
    }

    @objc func addPost() {
        print("user did press add button")
        // There is another instance of this function, if you change this one, change that one
        if let newScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as? NewPostViewController {
            newScreen.returningViewController = self
            self.present(newScreen, animated: true, completion: nil)
            whatsPlaying?.enterPausedState()
        }
    }
    
    @objc func userLoggedOut() {
        logUserOut()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        whatsPlaying?.enterPausedState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // These actions will occur every time the user switches back to the screen (via the tab bar for example)
        viewDidLoad()
    }
}

func logUserOut() {
    User.logOut()
    
    let main = UIStoryboard(name: "Main", bundle: nil)
    let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
    
    delegate.window?.rootViewController = loginViewController
}

extension PostTableViewCell {
    
}

// This should get moved to a different file at some point
// Some file for Post related functions I guess
func sortPosts(arr: [Post], completion: (@escaping ([Post]) -> ())) {
    var arrVar = arr
    if sortOrder == .random {
        arrVar.shuffle()
        completion(arrVar)
        return
    }
    func fetchIt(index: Int, completion: @escaping () -> ()) {
        
            arrVar[index].fetchIfNeededInBackground(block: { post, error in
                if index+1 < arrVar.count {
                    fetchIt(index: index+1) {
                        completion()
                    }
                }
                else {
                    completion()
                }
            })
        
    }
    
    fetchIt(index: 0) {
        arrVar.sort { post1, post2 in
            
            switch sortOrder {
            case .score:
                let scoreCompare = post1.calculatedScore > post2.calculatedScore
                let scoreEqual = post1.calculatedScore == post2.calculatedScore
                // If scores are equal, we rely on least downvoted
                return scoreCompare || post1.downvoteCount < post2.downvoteCount && scoreEqual
            case .downvotes:
                let downvoteCompare = post1.downvoteCount > post2.downvoteCount
                let downEqual = post1.downvoteCount == post2.downvoteCount
                // This is supposed to be a "controversial" sort
                // Most downvotes or, if equal, least score
                return downvoteCompare || post1.calculatedScore < post2.calculatedScore && downEqual
            case .recent:
                let scoreCompare = post1.calculatedScore > post2.calculatedScore
                guard let date1 = post1.createdAt, let date2 = post2.createdAt else {
                    return scoreCompare
                }
                
                // Extremely unlikely that these are ever equal, so I'll take the improper sort
                return date1.timeIntervalSince1970 > date2.timeIntervalSince1970
                
            case .oldest:
                let scoreCompare = post1.calculatedScore > post2.calculatedScore
                guard let date1 = post1.createdAt, let date2 = post2.createdAt else {
                    return scoreCompare
                }
                
                // Extremely unlikely that these are ever equal, so I'll take the improper sort
                return date1.timeIntervalSince1970 < date2.timeIntervalSince1970
            case .random:
                return Bool.random()
            }
                    
        }
        completion(arrVar)
    }
}

extension UIView {
    func scaleBounce(duration: CGFloat) {
        let duration = duration / 2.0
        UIView.animate(withDuration: duration,
            animations: {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        },
        completion: { _ in
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform.identity
            }
        })
    }
}
