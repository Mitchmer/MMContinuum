//
//  AddPostTableViewController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "addPostCell", for: indexPath)
//
//        return cell
//    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        postImageView.image = nil
        captionTextField.text = ""
        selectImageButton.setTitle("Select Image", for: .normal)
    }
    @IBAction func addImageButtonTapped(_ sender: Any) {
        selectImageButton.setTitle("", for: .normal)
        postImageView.image = UIImage(named: "spaceEmptyState.jpg")
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = postImageView.image, let text = captionTextField.text else { return }
        if text != "" {
            PostController.shared.createPostWith(image: image, caption: text) { (_) in }
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
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
