//
//  PostListTableViewController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [Post] {
        if isSearching {
            return resultsArray
        } else {
            return PostController.shared.posts
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postSearchBar.delegate = self
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        postSearchBar.text = ""
        isSearching = false
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        let post = resultsArray[indexPath.row]
        cell.post = post
        
        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destinationVC = segue.destination as? PostDetailTableViewController else { return }
                let post = resultsArray[indexPath.row]
                destinationVC.post = post
            }
        }
    }
}

extension PostListTableViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = PostController.shared.posts.filter { $0.matches(searchTerm: searchText) }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        postSearchBar.text = ""
        postSearchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
}
