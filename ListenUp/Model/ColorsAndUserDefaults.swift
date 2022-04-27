//
//  ColorsAndUserDefaults.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/24/22.
//

import Foundation
import SwiftUI
import UIKit

// Colors and UserDefaults - my upcoming album

let upvoteColor = UIColor.systemOrange
let downvoteColor = UIColor.systemIndigo
let favoriteColor = UIColor.systemPink


func overrideAccentColor(basedOn condition: Bool, with override: UIColor) -> UIColor {
    return condition ? override : jellyColor
}

func refreshForAccentColor() {
    let thisApp = UIApplication.shared
    
    thisApp.delegate?.window??.tintColor = jellyColor
}

var jellyColor : UIColor = UserDefaults.standard.colorForKey(key: "accentColor") ?? UIColor(Color.blue) {
    didSet {
        UserDefaults.standard.setColor(color: jellyColor, forKey: "accentColor")
        refreshForAccentColor()
    }
}

extension UserDefaults {
    func setColor(color: UIColor?, forKey key: String) {
        if let color = color {
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
                set(colorData, forKey: key)
            }
        }
        
    }
    func colorForKey(key: String) -> UIColor? {
        if let colorData = data(forKey: key) {
            if let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                return color
            }
        }
        return nil
    }
}
