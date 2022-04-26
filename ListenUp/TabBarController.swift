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

        guard let viewControllers = viewControllers else {
            return
        }
        
        print(viewControllers)
        
        if UserDefaults.standard.bool(forKey: "prefersPagedFeed") {
            
        }
    }

}
