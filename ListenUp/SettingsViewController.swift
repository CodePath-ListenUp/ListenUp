//
//  SettingsViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/24/22.
//

import SwiftUI
import UIKit


struct SettingsView: View {
    let parent: SettingsViewController
    
    @State private var preferredLayout: Bool = UserDefaults.standard.bool(forKey: "prefersPagedFeed")
    
    var body: some View {
        List {
            Section("Feed") {
                SettingToggleCell(settingName: "Paged Layout", toggleStatus: $preferredLayout)
                    .onChange(of: preferredLayout) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "prefersPagedFeed")
                        
                        guard let tabBarC = parent.tabBarController as? TabBarController else {
                            return
                        }
                        
                        tabBarC.setupAppropriateViews()
                    }
                Text("Sort Order")
                Text("Genre Filter")
                Text("Accent Color")
                Text("Avoid Explicit Content")
                Text("Display Score")
                    .disabled(preferredLayout)
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

struct SettingToggleCell: View {
    let settingName: String
    @Binding var toggleStatus: Bool
    
    var body: some View {
        HStack {
            Text(settingName)
            Spacer()
            Toggle("", isOn: $toggleStatus)
        }
    }
}

class SettingsViewController: UIViewController {
    
    var settingsView = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        
        settingsView = UIHostingController(rootView: SettingsView(parent: self))
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
