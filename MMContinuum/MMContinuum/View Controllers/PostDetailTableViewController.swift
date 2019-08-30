//
//  PostDetailTableViewController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    @IBOutlet weak var detailNavItem: UINavigationItem!
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = post else { return }
        PostController.shared.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateViews() {
        loadViewIfNeeded()
        guard let post = post else { return }
        detailNavItem.title = post.caption
        postImageView.image = post.photo
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
        return post.comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        guard let post = post else { return UITableViewCell() }
        let comment = post.comments[indexPath.row]
    
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = "\(comment.timestamp)"
    
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

    @IBAction func commentButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add Comment", message: "Comment on this post!", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Type Here..."
        }
        let addPostAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let postText = alertController.textFields?.first?.text, let post = self.post else { return }
            if postText != "" {
                PostController.shared.addComment(text: postText, post: post, completion: { (_) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
        let cancelPostAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(addPostAction)
        alertController.addAction(cancelPostAction)
        present(alertController, animated: true)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post else { return }
        let activityController = UIActivityViewController(activityItems: [post.caption], applicationActivities: nil )
        present(activityController, animated: true, completion: nil)
        
    }
    
    
    
}
