//
//  AddPostTableViewController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/27/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    var newImage: UIImage?
    
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        captionTextField.text = ""
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

    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = newImage, let text = captionTextField.text else { return }
        if text != "" {
            PostController.shared.createPostWith(image: image, caption: text) { (_) in }
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func cancelBarButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImageSelectorVC" {
            let imageSelector = segue.destination as? PhotoSelectorViewController
            imageSelector?.delegate = self
        }
    }

}

extension AddPostTableViewController : PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerImage(image: UIImage) {
        newImage = image
    }
}


