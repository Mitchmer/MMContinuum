//
//  PhotoSelectorViewController.swift
//  MMContinuum
//
//  Created by Mitch Merrell on 8/28/19.
//  Copyright © 2019 Mitch Merrell. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoSelectorViewControllerDelegate : class {
    func photoSelectorViewControllerImage(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        selectImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        presentImagePicker()
    }
    
    
}
extension PhotoSelectorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePicker() {
        let alertController = UIAlertController(title: "Select Image", message: "SHOW ME WHAT YOU GOT", preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: "Library", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postImageView.image = image
            delegate?.photoSelectorViewControllerImage(image: image)
        }
    }
}
