//
//  PostViewController.swift
//  ListenUp
//
//  Created by Harshad Barapatre on 4/18/22.
//

import UIKit

class NewPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [Post] = []
    var searchQuery = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Post"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        tableView.allowsSelection = false
        
        searchBar.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell") as? ResultTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        }
        
        let result = searchResults[indexPath.row]

        cell.albumArtworkView.image = UIImage(named: "default.jpg")!
        cell.trackNameLabel?.text = result.trackName
        cell.artistNameLabel?.text = result.artistName

        guard let albumArtworkURL = URL(string: result.artworkUrl100) else {
            return cell
        }

        cell.albumArtworkView?.load(url: albumArtworkURL)
        
        return cell
    }
    
    func getSearchResults(_ searchQuery: String) {
        retrieveITUNESResults(rawSearchTerm: searchQuery) { results in
            self.searchResults = results.map({ result in
                return Post(song: result, createdBy: User.current()!)
            })
            // Can't run UI code on background thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        getSearchResults(searchText)
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
   
