//
//  AccentColorPicker.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/27/22.
//

import SwiftUI

struct AccentColorPicker: View {
    let parent: SettingsViewController
    @Binding var colorPicked: Color
    
    let possibleColors: [String:Color] = [
        "Cherry":.red,
//        "Cherry": Color.init(red: 155.0/255.0, green: 20.0/255.0, blue: 23.0/255.0),
        "Strawberry": Color.init(red: 252.0/255.0, green: 90.0/255.0, blue: 141.0/255.0),
        "Grape": .purple,
        "Peach": Color(red: 255.0/255.0, green: 186.0/255.0, blue: 97.0/255.0),
        "Apple": Color.init(red: 140.0/255.0, green: 180.0/255.0, blue: 2.0/255.0),
        "Blueberry": .blue
    ]
    
    var body: some View {
        List(Array(possibleColors.keys.sorted()), id: \.self) { possibleColor in
            if let color = possibleColors[possibleColor] {
                Button(action: {
                    colorPicked = color
                    jellyColor = UIColor(color)
                }) {
                    AccentColorCell(name: possibleColor, color: possibleColors[possibleColor]!, colorPicked: $colorPicked)
                }
            }
            else {
                EmptyView()
            }
        }
        .onDisappear {
            parent.viewDidLoad()
        }
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

