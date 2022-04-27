//
//  ResultTableViewCell.swift
//  ListenUp
//
//  Created by Harshad Barapatre on 4/18/22.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumArtworkView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var postSymbol: UIImageView!
    @IBOutlet weak var mediaButton: UIButton!
    
    var result: SongResult? = nil
    
    var isPlaying: Bool = false
    let darkeningLayer = CALayer()
    let player = MusicPlayer()

    func enterPausedState() {
        self.isPlaying = false
        self.player.pause()
        self.darkeningLayer.opacity = nonPlayingArtworkOpacity
        self.mediaButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
    
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

}
