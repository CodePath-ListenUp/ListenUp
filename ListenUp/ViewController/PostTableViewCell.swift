//
//  PostTableViewCell.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var albumArtworkView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var upvoteSymbol: UIImageView!
    @IBOutlet weak var downvoteSymbol: UIImageView!
    @IBOutlet weak var heartIcon: UIImageView!
    @IBOutlet weak var mediaButton: UIButton!
    
    var post: Post? = nil
    
    var isPlaying: Bool = false
    let darkeningLayer = CALayer()
    let player = MusicPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        albumArtworkView.layer.cornerRadius = 8.0
        albumArtworkView.clipsToBounds = true
        mediaButton.layer.cornerRadius = 8.0
        mediaButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func upvote() {
        guard let post = self.post else {
            print("post has not been set yet")
            return
        }
        let upvoted = upvotePost(post: post)
        self.upvoteSymbol.scaleBounce(duration: 0.2)
        styleUpvoteSymbol(value: upvoted)
        self.downvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: downvoteColor)
    }
    func styleUpvoteSymbol(value: Bool) {
//        self.upvoteSymbol.image = UIImage(systemName: value ? "chevron.up.square.fill" : "chevron.up.square")
        self.upvoteSymbol.tintColor = overrideAccentColor(basedOn: value, with: upvoteColor)
    }
    
    func favorite() {
        guard let post = self.post else {
            print("post has not been set yet")
            return
        }
        
        let loved = heartPost(post: post)
        self.heartIcon.scaleBounce(duration: 0.2)
        self.updateHeartUI(favoriteStatus: loved)
    }
    
    func downvote() {
        guard let post = self.post else {
            print("post has not been set yet")
            return
        }
        
        let downvoted = downvotePost(post: post)
        self.downvoteSymbol.scaleBounce(duration: 0.2)
        self.downvoteSymbol.tintColor = overrideAccentColor(basedOn: downvoted, with: downvoteColor)
        self.upvoteSymbol.tintColor = overrideAccentColor(basedOn: false, with: upvoteColor)
    }
    
}
