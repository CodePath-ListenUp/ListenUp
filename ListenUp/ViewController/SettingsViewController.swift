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
    @State private var showingSortOrderAction = false
    
    @State private var color: Color = Color(uiColor: jellyColor)
    
    @State private var sortOrderString = sortOrder.rawValue
    
    var body: some View {
        NavigationView {
            List {
                Section("⚠️ Warning ⚠️") {
                    Text("Please consider all settings very experimental for the time being.")
                        .padding()
                }
                Section("Feed") {
                    SettingToggleCell(settingName: "Paged Layout", systemImage: "doc.richtext", toggleStatus: $preferredLayout, color: $color)
                        .onChange(of: preferredLayout) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "prefersPagedFeed")
                            
                            guard let tabBarC = parent.tabBarController as? TabBarController else {
                                return
                            }
                            
                            tabBarC.setupAppropriateViews()
                        }
                    SettingChoiceCell(settingName: "Sort Order", systemImage: "line.3.horizontal.decrease.circle.fill", choice: $sortOrderString, color: $color) {
                        showingSortOrderAction = true
                    }
                    .confirmationDialog("Text", isPresented: $showingSortOrderAction) {
                        ForEach(SortOrder.allCases, id: \.rawValue) { sort in
                            Button {
                                print(SortOrder.allCases)
                                UserDefaults.standard.setPreferredSortOrder(sort)
                                sortOrderString = sortOrder.rawValue
                            } label: {
                                Text(sort.rawValue)
                            }

                        }
                    }
                    Text("Genre Filter")
                    NavigationLink(destination: AccentColorPicker(parent: parent, colorPicked: $color)) {
                        SettingNavigationCell(title: "Accent Color", systemImage: "eyedropper.halffull", color: $color)
                    }
                    Text("Avoid Explicit Content")
                    Text("Display Score")
                        .disabled(preferredLayout)
                }
                .tint(color)
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
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Label("", systemImage: systemImage)
                .labelStyle(.iconOnly)
                .foregroundColor(color)
            Label(title, systemImage: "")
                .labelStyle(.titleOnly)
                .foregroundColor(.init(uiColor: .label))
            Spacer()
        }
    }
}

struct SettingToggleCell: View {
    let settingName: String
    let systemImage: String
    @Binding var toggleStatus: Bool
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Label("", systemImage: systemImage)
                .labelStyle(.iconOnly)
                .foregroundColor(color)
            Label(settingName, systemImage: "")
                .labelStyle(.titleOnly)
                .foregroundColor(.init(uiColor: .label))
            Spacer()
            Toggle("", isOn: $toggleStatus)
        }
    }
}

// This cell is designed to perform an action given to it.
// The fact that it will perform an action is suggested to the user by
// the name and the chevron on the right
struct SettingChoiceCell: View {
    let settingName: String
    let systemImage: String
    @Binding var choice: String
    @Binding var color: Color
    let action: (() -> ())?
    
    var view: some View {
        HStack {
            SettingNavigationCell(title: settingName, systemImage: systemImage, color: $color)
            Text(choice)
                .font(.subheadline)
        }
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

// This cell is designed to open a link, because of it's blue color
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
