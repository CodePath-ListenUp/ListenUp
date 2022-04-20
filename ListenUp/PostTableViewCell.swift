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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
