//
//  FeedViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/13/22.
//

import Foundation
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        navigationItem.title = "Feed"
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(addPost))
        ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        cell.trackNameLabel?.text = indexPath.row == 0 ? "Super extra long and epic title that won't be used later and even more text because I need at least 3 lines to test this" : "Track Name"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("user tried to open song: \((tableView.cellForRow(at: indexPath) as! PostTableViewCell).trackNameLabel!.text)")
    }
    
    @objc func addPost() {
        print("user did press add button")
    }
}



