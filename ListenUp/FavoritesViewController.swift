//
//  FavoritesViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/20/22.
//

import UIKit

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<100 {
            let label = UILabel()
            label.text = "nothing to see here :)"
            label.frame = .init(x: 100, y: 40*i, width: 300, height: 20)
            view.addSubview(label)
        }
    }


}
