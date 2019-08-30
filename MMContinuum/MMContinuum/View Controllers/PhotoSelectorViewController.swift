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
    
    let currentDevice = UIDevice.current.localizedModel
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        selectImageButton.setTitle("", for: .normal)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        presentImagePicker(sender: sender)
    }
    
    
}
extension PhotoSelectorViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePicker(sender: UIButton) {
        
        if currentDevice == "iPhone" {
            let alertController = UIAlertController(title: "Select Image", message: "SHOW ME WHAT YOU GOT", preferredStyle: .actionSheet)
            alertControllerSetUp(controller: alertController)
        } else {
            let alertController = UIAlertController(title: "Select Image", message: "SHOW ME WHAT YOU GOT", preferredStyle: .actionSheet)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceRect = sender.frame
                popoverController.sourceView = sender as UIView
            }
            alertControllerSetUp(controller: alertController)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            postImageView.image = image
            delegate?.photoSelectorViewControllerImage(image: image)
        }
    }
    
    func alertControllerSetUp(controller: UIAlertController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller.addAction(UIAlertAction(title: "Library", style: .default, handler: { (_) in
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        present(controller, animated: true)
    }
}
