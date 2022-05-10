//
//  AccentColorPicker.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/27/22.
//

import SwiftUI

//enum AccentColor: String, Comparable {
//    static func < (lhs: AccentColor, rhs: AccentColor) -> Bool {
//        lhs.rawValue < rhs.rawValue
//    }
//
//    case cherry = "Cherry"
//    case strawberry = "Strawberry"
//    case grape = "Grape"
//    case peach = "Peach"
//    case apple = "Apple"
//    case blueberry = "Blueberry"
//}

//struct JellyColor: Comparable, RawRepresentable {
//    init?(rawValue: String) {
//        self.name = rawValue
//    }
//
//    var rawValue: String
//
//    typealias RawValue = String
//
//    static func < (lhs: JellyColor, rhs: JellyColor) -> Bool {
//        lhs.name < rhs.name
//    }
//
//    var color: Color
//    var uiColor: UIColor { UIColor(color) }
//    var name: String
//
//    init(_ color: Color, name: String) {
//        self.color = color
//        self.name = name
//    }
//}


struct AccentColorPicker: View {
    let parent: SettingsViewController
    @Binding var colorPicked: Color
    
    let possibleColors: [String:UIColor] = [
        "Cherry": UIColor.init(red: 155.0/255.0, green: 20.0/255.0, blue: 23.0/255.0, alpha: 1.0),
        "Strawberry": UIColor.init(red: 252.0/255.0, green: 90.0/255.0, blue: 141.0/255.0, alpha: 1.0),
        "Grape": UIColor.systemPurple,
        "Peach": UIColor(red: 255.0/255.0, green: 186.0/255.0, blue: 97.0/255.0, alpha: 1.0),
        "Apple": UIColor.init(red: 140.0/255.0, green: 180.0/255.0, blue: 2.0/255.0, alpha: 1.0),
        "Blueberry": .systemBlue,
        "Lemon Curd": .systemYellow,
        "Raspberry":.systemRed,
        "Monoberry":.label
    ]
//    let possibleColors: [String:Color] = [
//        "Cherry": Color.init(red: 155.0/255.0, green: 20.0/255.0, blue: 23.0/255.0),
//        "Strawberry": Color.init(red: 252.0/255.0, green: 90.0/255.0, blue: 141.0/255.0),
//        "Grape": .purple,
//        "Peach": Color(red: 255.0/255.0, green: 186.0/255.0, blue: 97.0/255.0),
//        "Apple": Color.init(red: 140.0/255.0, green: 180.0/255.0, blue: 2.0/255.0),
//        "Blueberry": .blue,
//        "Lemon Curd": .yellow,
//        "Raspberry":.red,
//        "Monoberry":.primary
//    ]
    
    var body: some View {
        
        List(Array(possibleColors.keys.sorted()), id: \.self) { possibleColor in
            if let color = possibleColors[possibleColor] {
                Button(action: {
                    colorPicked = .init(uiColor: color)
                    jellyColor = color
                }) {
                    AccentColorCell(name: possibleColor, color: .init(uiColor: possibleColors[possibleColor]!), colorPicked: $colorPicked)
                }
            }
            else {
                EmptyView()
            }
        }
        .onDisappear {
            parent.viewDidLoad()
        }
        .navigationTitle(Text("Accent Color"))
    }
}

struct AccentColorCell: View {
    let name: String
    let color: Color
    @Binding var colorPicked: Color
    var body: some View {
        HStack {
            Label("", systemImage: "circle.fill")
                .foregroundColor(color)
                .labelStyle(.iconOnly)
            Label(name, systemImage: "circle.fill")
                .foregroundColor(.init(uiColor: .label))
                .labelStyle(.titleOnly)
            Spacer()
            if UIColor(color).cgColor.components == UIColor(colorPicked).cgColor.components {
                Image(systemName: "checkmark")
                    .foregroundColor(color)
            }
            
        }
    }
}

