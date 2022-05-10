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

enum AppTheme: String, CaseIterable {
    case device = "Device Theme"
    case dark = "Dark"
    case light = "Light"
}

func getUserInterfaceStyle(forAppTheme aT: AppTheme) -> UIUserInterfaceStyle {
    switch aT {
    case .device:
        return .unspecified
    case .dark:
        return .dark
    case .light:
        return .light
    }
}

var preferredAppTheme: AppTheme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "preferredAppTheme") ?? "Device") ?? .device {
    didSet {
        UserDefaults.standard.set(preferredAppTheme.rawValue, forKey: "preferredAppTheme")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController?.overrideUserInterfaceStyle = getUserInterfaceStyle(forAppTheme: preferredAppTheme)
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
