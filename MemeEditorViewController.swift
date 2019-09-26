//
//  MemeEditorViewController.swift
//  imagePicker
//
//  Created by Nammy Dun on 27/6/2019.
//  Copyright © 2019 Nammy Dun. All rights reserved.
//

import UIKit
import Photos

class MemeEditorViewController: UIViewController{
    
    @IBOutlet var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextfield: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    var meme: Meme?
    
    
    // Set the Meme Text Attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
        .strokeWidth: -6
        
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTextField(topTextfield, text: "TOP")
        setupTextField(bottomTextfield, text: "BOTTOM")
        topTextfield.delegate = self
        bottomTextfield.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // Disable the camera button when camera is not avaliable
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }
    
    // Subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // Unsubscribe to keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // Keyboard will show and view will move up when begin editing textfields
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        if  bottomTextfield.isEditing == true  {
            self.view.frame.origin.y -= keyboardSize.cgRectValue.height
        }
        
    }
    
    // Keyboard will disappear and view will move down when finished editing textfields
    @objc func keyboardWillHide(_ notification:Notification) {
        
        self.view.frame.origin.y = 0
        
    }
    
    // Keyboard will disappear
    @objc func hideKeyboard() {
        
        view.endEditing(true)
        
    }
    
    // Pick an image from album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        let albumImagePicker = UIImagePickerController()
        albumImagePicker.delegate = self
        albumImagePicker.sourceType = .photoLibrary
        present(albumImagePicker, animated: true, completion: nil)
        
    }
    
    // Take an image from camera
    @IBAction func takeAnImageFromCamera(_ sender: Any) {
        
        let cameraImagePicker = UIImagePickerController()
        cameraImagePicker.delegate = self
        cameraImagePicker.sourceType = .camera
        present(cameraImagePicker, animated: true, completion: nil)
        
    }
    
    // Share image from activity view controller
    @IBAction func shareImage(_ sender: Any) {
        
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
        
    }
    
    // Returns to its launch state with no image and default text
    @IBAction func cancelAll(_ sender: Any) {
        
        imagePickerView.image = nil
        setupTextField(topTextfield, text: "TOP")
        setupTextField(bottomTextfield, text: "BOTTOM")
        
    }
    
    // To save meme image
    func save() {
        
        // Create the meme
        let meme = Meme(topText: topTextfield.text, bottomText: bottomTextfield.text, originalImage: imagePickerView.image, memedImage: generateMemedImage())
        
    }
    
}

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Show the selcted image on screen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        
        if let image = info [.originalImage] as? UIImage{
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // Generate a memed image
    func generateMemedImage() -> UIImage {
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.imagePickerView.frame.size)
        view.drawHierarchy(in: CGRect(x: 0, y: -44-34, width: view.frame.width, height: self.view.frame.height), afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
        
    }
    
}
extension MemeEditorViewController: UITextFieldDelegate {
    
    // Setup textfields
    func setupTextField(_ textField: UITextField, text: String) {
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 0
        textField.text = text
        textField.placeholder = text
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.text == textField.placeholder {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
