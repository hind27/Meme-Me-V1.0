//
//  ViewController.swift
//  Meme Me
//
//  Created by hind on 11/19/18.
//  Copyright © 2018 hind. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate , UITextFieldDelegate {
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var toptoolbar: UIToolbar!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var camerButton: UIBarButtonItem!
   
   
    
    //MARK: -Meme model
    
    override func viewDidLoad() {
        super.viewDidLoad()
       imagePicker.contentMode = .scaleAspectFit
         actionButton.isEnabled = false
        setupTextField(topTextField, text: "TOP")
        setupTextField(bottomTextField, text: "BOTTOM")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //check if camera is not available //simulator
        camerButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
   
    @IBAction func cancelmeme(_ sender: Any) {
        actionButton.isEnabled = false
        imagePicker.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        toptoolbar.resignFirstResponder()
        bottomToolbar.resignFirstResponder()
    }
    @IBAction func sharememe(_ sender: Any) {
        let memeimage = generateMemedImage()
        //define an instance of the ActivityViewController
         let activityViewController = UIActivityViewController(activityItems: [memeimage], applicationActivities: nil)
        //pass the ActivityViewController a memedImage as an activity item
        activityViewController.completionWithItemsHandler = { activity , completed , items, error in
            if completed
            {    // seve the image
                self.save()
                //Dismiss the Activity View
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    //MAEK: -Textfelid
    
    let memeTextAttributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.white,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.black,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue:  -4
    ]
    
    func setupTextField(_ textField: UITextField, text: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - pickAnImage
    
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
      
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
           imagePicker.image = image
             imagePicker.contentMode = .scaleAspectFit
            actionButton.isEnabled = true
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.image = image
            actionButton.isEnabled = true
            
        }
           dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - initilizes
    
    func save() {
        let memeimage = generateMemedImage()
        // Create the meme
        var meme = Meme(top: topTextField.text!,
                        bottom: bottomTextField.text!,
                        image: imagePicker.image!,
                        memedImage: memeimage)
    }
    
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        setToolbarState(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Show toolbar and navbar
        setToolbarState(false)
        return memedImage
    }
    
    
    //MARK:- set toolbar state
    func setToolbarState(_ hidden: Bool) {
        toptoolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    // MARK: - Keyboar
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),
                                               name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object: nil);
    }
    
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification as Notification) // Move view  upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
    
    
    //MARK -: Sharing a meme
    
    
}

