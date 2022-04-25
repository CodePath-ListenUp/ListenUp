//
//  SettingsViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/24/22.
//

import SwiftUI
import UIKit


struct SettingsView: View {
    var body: some View {
        List {
            Section("Feed") {
                Text("Preferred Layout")
                Text("Sort Order")
                Text("Display Score")
            }
            Section("Account") {
                Button(action: {
                    logUserOut()
                }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            Section("About") {
                Text("Privacy Policy")
                Text("Share App")
            }
        }
    }
}


class SettingsViewController: UIViewController {
    
    let settingsView = UIHostingController(rootView: SettingsView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        addChild(settingsView)
        view.addSubview(settingsView.view)
        setupContraints()
    }
    
    fileprivate func setupContraints() {
        settingsView.view.translatesAutoresizingMaskIntoConstraints = false
        settingsView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        settingsView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        settingsView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        settingsView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
}
