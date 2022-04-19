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
    
//    var result: Post? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
