//
//  SettingsViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/24/22.
//

import SwiftUI
import UIKit
import SafariServices


struct SettingsView: View {
    let parent: SettingsViewController
    
    @State private var preferredLayout: Bool = UserDefaults.standard.bool(forKey: "prefersPagedFeed")
    
    @State private var presentingLogOutConfirmation = false
    
    @State private var color = Color(uiColor: jellyColor)
    
    var body: some View {
        NavigationView {
            List {
                Section("⚠️ Warning ⚠️") {
                    Text("Please consider all settings very experimental for the time being.")
                        .padding()
                }
                Section("Feed") {
                    SettingToggleCell(settingName: "Paged Layout", systemImage: "doc.richtext", toggleStatus: $preferredLayout)
                        .onChange(of: preferredLayout) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "prefersPagedFeed")
                            
                            guard let tabBarC = parent.tabBarController as? TabBarController else {
                                return
                            }
                            
                            tabBarC.setupAppropriateViews()
                        }
                    Text("Sort Order")
                    Text("Genre Filter")
                    NavigationLink(destination: AccentColorPicker(parent: parent, colorPicked: $color)) {
                        SettingNavigationCell(title: "Accent Color", systemImage: "eyedropper.halffull")
                    }
                    Text("Avoid Explicit Content")
                    Text("Display Score")
                        .disabled(preferredLayout)
                }
                Section("Account") {
                    Button(action: {
                        presentingLogOutConfirmation = true
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .alert(isPresented: $presentingLogOutConfirmation) {
                        Alert(title: Text("Are you sure you want to log out?"), primaryButton: .default(Text("Cancel").foregroundColor(.init(uiColor: jellyColor))), secondaryButton: .destructive(Text("Log Out").fontWeight(.heavy), action: {
                            logUserOut()
                        }))
                        
                    }
                }
                Section("About") {
                    SettingLinkCell(linkTitle: "Privacy Policy", systemImage: "lock.fill") {
                        guard let url = URL(string: "https://privacy.jellyclub.app") else {
                            return
                        }
                        let svc = SFSafariViewController(url: url)
                        svc.preferredControlTintColor = jellyColor
                        parent.present(svc, animated: true)
                    }
                    SettingLinkCell(linkTitle: "Share JellyClub", systemImage: "square.and.arrow.up") {
                        let ac = UIActivityViewController(activityItems: [URL(string: "https://jellyclub.app")!,"Join the JellyClub and share your jams!"], applicationActivities: nil)
                        parent.present(ac, animated: true)
                    }
                }
            }
            .navigationTitle("Settings")
            
        }
        .tint(color)
    }
}

// This cell is designed to take the user to another screen made by the app
// (not a URL)
// In theory, this would be encapsulated in a NavigationLink
struct SettingNavigationCell: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
        }
    }
}

struct SettingToggleCell: View {
    let settingName: String
    let systemImage: String
    @Binding var toggleStatus: Bool
    
    var body: some View {
        HStack {
            Label(settingName, systemImage: systemImage)
            Spacer()
            Toggle("", isOn: $toggleStatus)
        }
    }
}

// This cell is designed to open a link in a Safari View Controller
struct SettingLinkCell: View {
    let linkTitle: String
    let systemImage: String
    let action: (() -> ())?
    
    var view: some View {
        HStack {
            Label(linkTitle, systemImage: systemImage)
            Spacer()
            Image(systemName: "chevron.right")
        }
            .foregroundColor(.blue)
    }
    
    var body: some View {
        if action != nil {
            Button(action: {action!()}) {
                view
            }
        }
        else {
            view
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

struct Previews_SettingsViewController_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(parent: SettingsViewController())
    }
}
