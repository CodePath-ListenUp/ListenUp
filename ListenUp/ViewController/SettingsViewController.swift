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
    @State private var prefersCleanContent: Bool = UserDefaults.standard.bool(forKey: "prefersCleanContent")
    @State private var displaysScore: Bool = UserDefaults.standard.bool(forKey: "showsScoreLabel")
    @State private var prefersPlainBackground: Bool = plainBackground
    
    @State private var presentingLogOutConfirmation = false
    @State private var showingSortOrderAction = false
    
    @State private var color: Color = Color(uiColor: jellyColor)
    @State private var genre: String = filteringGenre
    
    @State private var sortOrderString = sortOrder.rawValue
    
    var body: some View {
        NavigationView {
            List {
                Section("Feed") {
                    SettingToggleCell(settingName: "Paged Layout", systemImage: "doc.richtext", toggleStatus: $preferredLayout, color: $color)
                        .onChange(of: preferredLayout) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "prefersPagedFeed")
                            
                            guard let tabBarC = parent.tabBarController as? TabBarController else {
                                return
                            }
                            
                            tabBarC.setupAppropriateViews()
                        }
                    SettingToggleCell(settingName: "Plain Paged Background", systemImage: "dial.min.fill", toggleStatus: $prefersPlainBackground, color: $color)
                        .onChange(of: prefersPlainBackground) { newValue in
                            plainBackground = newValue
                        }
                    SettingToggleCell(settingName: "Censor Explicit Names", systemImage: "ear.trianglebadge.exclamationmark", toggleStatus: $prefersCleanContent, color: $color)
                        .onChange(of: prefersCleanContent) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "prefersCleanContent")
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

                    NavigationLink(destination: AccentColorPicker(parent: parent, colorPicked: $color)) {
                        SettingNavigationCell(title: "Accent Color", systemImage: "eyedropper.halffull", color: $color)
                    }
                    
                    NavigationLink { GenrePickerView(currentGenre: $genre) } label: {
                        SettingNavigationCell(title: "Genre Filter", systemImage: "guitars", color: $color) {
                            Text(genre).font(.subheadline).foregroundColor(color)
                        }
                    }
                    .disabled(false)
//                    SettingToggleCell(settingName: "Display Post Scores", systemImage: "27.square.fill", toggleStatus: $displaysScore, color: $color)
//                        .onChange(of: displaysScore) { newValue in
//                            UserDefaults.standard.set(newValue, forKey: "showsScoreLabel")
//                        }
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
struct SettingNavigationCell<Content: View>: View {
    internal init(title: String, systemImage: String, color: Binding<Color>, accessory: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self._color = color
        self.accessory = accessory()
    }
    
    let title: String
    let systemImage: String
    @Binding var color: Color
    @ViewBuilder var accessory: Content
    
    var body: some View {
        HStack {
            Label("", systemImage: systemImage)
                .labelStyle(.iconOnly)
                .foregroundColor(color)
            Label(title, systemImage: "")
                .labelStyle(.titleOnly)
                .foregroundColor(.init(uiColor: .label))
            Spacer()
//            if let content = accessory {
                accessory
//            }
        }
    }
}

extension SettingNavigationCell where Content == EmptyView {
    init(title: String, systemImage: String, color: Binding<Color>) {
        self.init(title: title, systemImage: systemImage, color: color, accessory: {EmptyView()})
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
            SettingNavigationCell(title: settingName, systemImage: systemImage, color: $color, accessory: {
                HStack {
                    Spacer()
                    
                    Text(choice)
                        .font(.subheadline)
                    NavigationLink.empty.frame(maxWidth: 10, alignment: .trailing) //needs the maxWidth: 10 limit in order to match the others
                   
                }
            })
            
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

extension NavigationLink where Label == EmptyView, Destination == EmptyView {

   /// Useful in cases where a `NavigationLink` is needed but there should not be
   /// a destination. e.g. for programmatic navigation.
   static var empty: NavigationLink {
       self.init(destination: EmptyView(), label: { EmptyView() })
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
