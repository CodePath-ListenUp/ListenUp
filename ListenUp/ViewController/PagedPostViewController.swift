//
//  PagedPostViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/26/22.
//

import MarqueeLabel
import UIKit

class PagedPostViewController: UIViewController {

    var post: Post!
    
    @IBOutlet weak var trackNameLabel: MarqueeLabel!
    @IBOutlet weak var artistNameLabel: MarqueeLabel!
    @IBOutlet weak var albumArtworkView: UIImageView!
    
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var downvoteSymbol: UIButton!
    @IBOutlet weak var upvoteSymbol: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var songwhipButton: UIButton!
    @IBOutlet weak var heartIcon: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let clean = UserDefaults.standard.bool(forKey: "prefersCleanContent")
        trackNameLabel.text = clean ? post.trackCensoredName : post.trackName
        artistNameLabel.text = post.artistName
        albumArtworkView.load(url: URL(string: post.artworkUrl750)!)
        
        // Button setup here
        mediaButton.addTarget(self, action: #selector(userTappedMediaButton), for: .touchUpInside)
    }
    
    @objc func userTappedMediaButton() {
        print("media button")
    }
}
