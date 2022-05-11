//
//  PagedPostViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/26/22.
//

import AVFoundation
import CoreMedia
import MarqueeLabel
import ProgressHUD
import SafariServices
import SwiftUI
import UIKit


class PagedPostViewController: UIViewController {

    var post: Post!
    
    @IBOutlet weak var containerBackground: UIView!
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
    var isPlaying: Bool = false
    var isViewInFocus = false {
        didSet {
            if !isViewInFocus {
                enterPausedState()
            }
        }
    }
    
    var weArePartying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerBackground.layer.opacity = 0
        
        
        
        let clean = UserDefaults.standard.bool(forKey: "prefersCleanContent")
        trackNameLabel.text = clean ? post.trackCensoredName : post.trackName
        artistNameLabel.text = post.artistName
        albumArtworkView.load(url: URL(string: post.artworkUrl750)!) {
            self.startTheParty()
        }
        
        trackNameLabel.backgroundColor = .clear
        
        self.mediaButton.tintColor = jellyColor
        shareButton.tintColor = jellyColor
        songwhipButton.tintColor = jellyColor
        
        if let user = User.current() {
            user.fetchIfNeededInBackground { success, error in
                // lol this is kinda backwards but oh well
                guard let error = error else {
                    self.styleUpvoteSymbol(value: self.post.isContainedIn(arr: user.upvotedPosts))
                    self.styleDownvoteSymbol(value: self.post.isContainedIn(arr: user.downvotedPosts))
                    self.updateHeartUI(favoriteStatus: self.post.isContainedIn(arr: user.favoritedPosts))
                    return
                }
                print("error: \(error.localizedDescription)")
            }
        }
        
        // Button setup here
        mediaButton.addTarget(self, action: #selector(userTappedMediaButton), for: .touchUpInside)
        downvoteSymbol.addTarget(self, action: #selector(userTappedDownvoteSymbol), for: .touchUpInside)
        upvoteSymbol.addTarget(self, action: #selector(userTappedUpvoteSymbol), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(userTappedShareButton), for: .touchUpInside)
        songwhipButton.addTarget(self, action: #selector(userTappedSongWhipButton), for: .touchUpInside)
        heartIcon.addTarget(self, action: #selector(userTappedheartIcon), for: .touchUpInside)
        
        
        mediaButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isViewInFocus = true
        player.initPlayer(url: post.previewUrl) {
            if self.isViewInFocus {
                self.player.pause()
                self.player.player.seek(to: CMTime.zero)
                self.enterPlayingState()
            }
        }
        if self.isViewInFocus {
            enterPlayingState()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isViewInFocus = false
        enterPausedState()
    }
    
    @objc func userTappedMediaButton(_ sender: UIButton) {
        mediaButton.scaleBounce(duration: 0.2)
        if isPlaying {
            enterPausedState()
        }
        else {
            enterPlayingState()
        }
    }
    
   
    
    func enterPlayingState() {
        isPlaying = true
        mediaButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        player.play()
    }
    
    @objc func userTappedDownvoteSymbol(_ sender: UIButton) {
        print("downvote symbol")
        let downvoted = downvotePost(post: post)
        self.downvoteSymbol.scaleBounce(duration: 0.2)
        styleUpvoteSymbol(value: false)
        styleDownvoteSymbol(value: downvoted)
    }
    
    @objc func userTappedUpvoteSymbol(_ sender: UIButton) {
        print("upvote symbol")
        let upvoted = upvotePost(post: post)
        self.upvoteSymbol.scaleBounce(duration: 0.2)
        styleUpvoteSymbol(value: upvoted)
        styleDownvoteSymbol(value: false)
    }
    
    @objc func userTappedShareButton(_ sender: UIButton) {
        print("share button")
        let trackName = "Check out \(post.trackName) by \(post.artistName):\n"
        let trackURL = post.songLinkString
        let ac = UIActivityViewController(activityItems: [trackName,trackURL ?? ""], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    // https://stackoverflow.com/a/58017164
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            startTheParty()
        }
    }
    
    func startTheParty() {
        
        // Only works if image is properly loaded, user has not set the plain background setting, and the user is in dark mode.
        guard let image = self.albumArtworkView.image, !plainBackground, self.traitCollection.userInterfaceStyle == .dark else {
            return
        }
        weArePartying = true
        DispatchQueue.global(qos: .background).async {
            guard let colors = image.getColors(quality: .low) else {
                return
            }
            DispatchQueue.main.async {
                let host = BackgroundOfLoginViewController(uiColors: [colors.secondary,colors.primary, colors.detail,colors.background])
                self.addChild(host)
                self.containerBackground.addSubview(host.view)
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut) {
                    self.containerBackground.layer.opacity = 1.0
                    self.styleAllButtons(color: .white)
                }
            }
        }
    }
    
    @objc func userTappedSongWhipButton(_ sender: UIButton) {
        print("songwhip button")
        openPost(post: post)
    }
    
    func enterPausedState() {
        self.isPlaying = false
        self.player.pause()
//        self.darkeningLayer.opacity = nonPlayingArtworkOpacity
        self.mediaButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
    
    func updateHeartUI(favoriteStatus: Bool) {
        DispatchQueue.main.async {
            self.heartIcon.setImage(UIImage(systemName: favoriteStatus ? "heart.fill" : "heart"), for: .normal)
            if self.weArePartying == false {
                self.heartIcon.tintColor = overrideAccentColor(basedOn: favoriteStatus, with: favoriteColor)
            }
        }
    }
    
    @objc func userTappedheartIcon(_ sender: UIButton) {
        print("heart icon")
        let loved = heartPost(post: post)
        self.heartIcon.scaleBounce(duration: 0.2)
        self.updateHeartUI(favoriteStatus: loved)
    }
    
    func openPost(post: Post) {
        if let songwhipStr = post.songLinkString, let url = URL(string: songwhipStr) {
            let svc = SFSafariViewController(url: url)
            svc.preferredControlTintColor = jellyColor
            DispatchQueue.main.async {
                self.present(svc, animated: true)
            }
        }
        else {
            getSongwhipFromLink(linkString: post.trackViewUrl) { result in
                self.post.songLinkString = result.url
                let url = URL(string: result.url)!
                let svc = SFSafariViewController(url: url)
                svc.preferredControlTintColor = jellyColor
                DispatchQueue.main.async {
                    self.present(svc, animated: true)
                }
            }
        }
    }
    
    func styleUpvoteSymbol(value: Bool) {
        if weArePartying == false {
            upvoteSymbol.tintColor = overrideAccentColor(basedOn: value, with: upvoteColor)
        }
        upvoteSymbol.setImage(UIImage(systemName: value ? "arrow.up.circle.fill" : "arrow.up.circle"), for: .normal)
    }
    
    func styleDownvoteSymbol(value: Bool) {
        if weArePartying == false {
            downvoteSymbol.tintColor = overrideAccentColor(basedOn: value, with: downvoteColor)
        }
        downvoteSymbol.setImage(UIImage(systemName: value ? "arrow.down.circle.fill" : "arrow.down.circle"), for: .normal)
    }
    
    func styleAllButtons(color: UIColor) {
        [self.upvoteSymbol,
         self.downvoteSymbol,
         self.heartIcon,
         self.shareButton,
         self.songwhipButton,
         self.mediaButton].forEach { element in
            element?.tintColor = color
        }
    }
}
