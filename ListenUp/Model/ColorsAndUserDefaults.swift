//
//  ColorsAndUserDefaults.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/24/22.
//

import Foundation
import UIKit

// Colors and UserDefaults - my upcoming album


var accentColor : UIColor {
    get {
        return UserDefaults.standard.colorForKey(key: "accentColor") ?? UIColor(named: "AccentColor")!
    }
    set {
        UserDefaults.standard.setColor(color: newValue, forKey: "accentColor")
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
