//
//  TabBarController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/26/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        DispatchQueue.main.async {
            self.setupAppropriateViews()
        }
        
        print(jellyColor)
        
        
    }

    func setupAppropriateViews() {
        if UserDefaults.standard.bool(forKey: "prefersPagedFeed") {
            let vc = PageViewTemplateController()
            let navOuter = UINavigationController(rootViewController: vc)
            vc.title = "Feed"
            vc.feedType = .all(Void()) // when genres get implemented, this is how we'll specify it
            navOuter.navigationBar.prefersLargeTitles = false
            navOuter.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "music.note.list"), selectedImage: UIImage(systemName:"music.note.list"))
            self.viewControllers?[0] = navOuter
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let feedNav = storyboard.instantiateViewController(withIdentifier: "feedNav")
            let favNav = storyboard.instantiateViewController(withIdentifier: "favNav")
            
            self.viewControllers?[0] = feedNav
            self.viewControllers?[1] = favNav
        }
        
        //if UserDefaults.standard.bool(forKey: "prefersPagedFavorites") {
        //            let vc = PageViewTemplateController()
        //            let navOuter = UINavigationController(rootViewController: vc)
        //            vc.title = "Feed"
        //            if let user = User.current() {
        //                vc.feedType = .favorites(user: user)
        //            }
        //            else {
        //                vc.feedType = .all(genre: .all)
        //            }
        //            navOuter.navigationBar.prefersLargeTitles = false
        //            navOuter.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "music.note.list"), selectedImage: UIImage(systemName:"music.note.list"))
        //            self.viewControllers?[1] = navOuter
        //        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            tabBarController?.tabBar.tintColor = jellyColor
        }
    }
}
