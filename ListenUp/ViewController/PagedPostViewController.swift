//
//  PagedPostViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/26/22.
//

import MarqueeLabel
import UIKit
import SafariServices

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
    
    let player = MusicPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let clean = UserDefaults.standard.bool(forKey: "prefersCleanContent")
        trackNameLabel.text = clean ? post.trackCensoredName : post.trackName
        artistNameLabel.text = post.artistName
        albumArtworkView.load(url: URL(string: post.artworkUrl750)!)
        
        // Button setup here
        mediaButton.addTarget(self, action: #selector(userTappedMediaButton), for: .touchUpInside)
        downvoteSymbol.addTarget(self, action: #selector(userTappedDownvoteSymbol), for: .touchUpInside)
        upvoteSymbol.addTarget(self, action: #selector(userTappedUpvoteSymbol), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(userTappedShareButton), for: .touchUpInside)
        songwhipButton.addTarget(self, action: #selector(userTappedSongWhipButton), for: .touchUpInside)
        heartIcon.addTarget(self, action: #selector(userTappedheartIcon), for: .touchUpInside)
    }
    
    @objc func userTappedMediaButton(_ sender: UIButton) {
        print("media button")
    }
    
    @objc func userTappedDownvoteSymbol(_ sender: UIButton) {
        print("downvote symbol")
        let downvoted = downvotePost(post: post)
        self.downvoteSymbol.scaleBounce(duration: 0.2)
        self.downvoteSymbol.tintColor = overrideAccentColor(basedOn: downvoted, with: downvoteColor)
        self.upvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: upvoteColor)
    }
    
    @objc func userTappedUpvoteSymbol(_ sender: UIButton) {
        print("upvote symbol")
        let upvoted = upvotePost(post: post)
        self.upvoteSymbol.scaleBounce(duration: 0.2)
        self.upvoteSymbol.tintColor = overrideAccentColor(basedOn: upvoted, with: upvoteColor)
        self.downvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: downvoteColor)
    }
    
    @objc func userTappedShareButton(_ sender: UIButton) {
        print("share button")
        let trackName = post.trackName
        let trackURL = post.trackViewUrl
        let ac = UIActivityViewController(activityItems: [trackName, trackURL], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func userTappedSongWhipButton(_ sender: UIButton) {
        print("songwhip button")
        openPost(post: post)
    }
    
    @objc func userTappedheartIcon(_ sender: UIButton) {
        print("heart icon")
        let loved = heartPost(post: post)
        self.heartIcon.scaleBounce(duration: 0.2)
        self.heartIcon.tintColor = overrideAccentColor(basedOn: loved, with: favoriteColor)
    }
    
    func openPost(post: Post) {
        if let songwhipStr = post.songLinkString, let url = URL(string: songwhipStr) {
            let svc = SFSafariViewController(url: url)
            DispatchQueue.main.async {
                self.present(svc, animated: true)
            }
        }
        else {
            getSongwhipFromLink(linkString: post.trackViewUrl) { result in
                self.post.songLinkString = result.url
                let url = URL(string: result.url)!
                let svc = SFSafariViewController(url: url)
                DispatchQueue.main.async {
                    self.present(svc, animated: true)
                }
            }
        }
    }
}
