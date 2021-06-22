//
//  ViewController.swift
//  PhotoCropController
//
//  Created by azure-may on 06/22/2021.
//  Copyright (c) 2021 azure-may. All rights reserved.
//

import UIKit
import PhotosUI
import PhotoCropController

class ViewController: UIViewController, PhotoCropDelegate {
    
    var image: UIImage? { didSet { imageView.image = image } }

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImage(_ sender: Any) {
        browsePhotoLibrary()
    }
}

//MARK: - ImagePicker Delegate Methods

extension ViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func browsePhotoLibrary() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.filter = PHPickerFilter.images
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .compatible
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = edited
        } else if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = selected
        }
        presentedViewController?.dismiss(animated: true)
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let provider = results.last?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                if let image = result as? UIImage {
                    DispatchQueue.main.async { self?.select(image: image) }
                } else if let error = error {
                    NSLog("Error picking image: %@", error.localizedDescription)
                    DispatchQueue.main.async { picker.dismiss(animated: true) }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func select(image: UIImage) {
        let destinationSize = AVMakeRect(aspectRatio: image.size, insideRect: view.frame).integral.size
        //Best Performance
        let resizedImage = UIGraphicsImageRenderer(size: destinationSize).image { (context) in
            image.draw(in: CGRect(origin: .zero, size: destinationSize))
        }
        let cropController = PhotoCropController()
        cropController.delegate = self
        cropController.image = resizedImage
        presentedViewController?.present(cropController, animated: true)
    }
    
    @objc func cropViewDidCrop(image: UIImage?) {
        self.image = image
        presentedViewController?.dismiss(animated: true) { [weak self] in
            self?.presentedViewController?.dismiss(animated: true)
        }
    }
}


