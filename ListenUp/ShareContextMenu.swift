//
//  ShareContextMenu.swift
//  ListenUp
//
//  Created by Harshad Barapatre on 4/20/22.
//

import Foundation
import UIKit
import SwiftUI

func getContextMenuChildren(_ controller: UIViewController, _ item: SongResult) -> [UIAction] {
    let shareAction =
        UIAction(title: NSLocalizedString("Share", comment: ""),
                 image: UIImage(systemName: "square.and.arrow.up")) { action in
            print("User selected share button")
            
            let trackName = item.trackName
            let trackURL = item.trackViewUrl
            let ac = UIActivityViewController(activityItems: [trackName, trackURL], applicationActivities: nil)
            controller.present(ac, animated: true)
        }
    return [shareAction]
}
