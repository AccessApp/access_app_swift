//
//  AddPlaceViewController.swift
//  places
//
//  Created by Deyan Marinov on 8.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class AddPlaceViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    var activeField: UITextView?
    
    @IBOutlet var placeNameTV: UITextView! {
        didSet {
            placeNameTV.tag = 1
            placeNameTV.layer.masksToBounds = true
            placeNameTV.layer.cornerRadius = 5
            placeNameTV.contentInset.top = 5.0
            placeNameTV.layer.borderWidth = 1
            placeNameTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
            placeNameTV.text = "Enter name of place..."
        }
    }
    
    @IBOutlet var locationTV: UITextView! {
        didSet {
            locationTV.tag = 2
            locationTV.layer.masksToBounds = true
            locationTV.layer.cornerRadius = 5
            locationTV.contentInset.top = 5.0
            locationTV.layer.borderWidth = 1
            locationTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    @IBOutlet var descTV: UITextView! {
        didSet {
            descTV.tag = 3
            descTV.layer.masksToBounds = true
            descTV.layer.cornerRadius = 5
            descTV.layer.borderWidth = 1
            descTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    @IBOutlet var urlTV: UITextView! {
        didSet {
            urlTV.tag = 4
            urlTV.layer.masksToBounds = true
            urlTV.layer.cornerRadius = 5
            urlTV.contentInset.top = 5.0
            urlTV.layer.borderWidth = 1
            urlTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        
        placeNameTV.delegate = self
//        placeNameTV.becomeFirstResponder()
        placeNameTV.selectedTextRange = placeNameTV.textRange(from: placeNameTV.beginningOfDocument, to: placeNameTV.beginningOfDocument)
        locationTV.delegate = self
        locationTV.selectedTextRange = locationTV.textRange(from: locationTV.beginningOfDocument, to: locationTV.beginningOfDocument)
        descTV.delegate = self
        descTV.selectedTextRange = descTV.textRange(from: descTV.beginningOfDocument, to: descTV.beginningOfDocument)
        urlTV.delegate = self
        urlTV.selectedTextRange = urlTV.textRange(from: urlTV.beginningOfDocument, to: urlTV.beginningOfDocument)
        self.registerForKeyboardNotifications()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }
    
    func setupCustomNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let logo = UIImageView()
        logo.image = UIImage(named: "logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        let contentView = UIView()
        self.navigationItem.titleView = contentView
        self.navigationItem.titleView?.addSubview(logo)
        logo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        self.navigationItem.titleView?.addSubview(logo)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 12.0)!]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            switch textView.tag {
            case 1:
                textView.text = "Enter name of place..."
            case 2:
                textView.text = "Enter location..."
            case 3:
                textView.text = "Describe the place..."
            case 4:
                textView.text = "Enter place url..."
            default:
                textView.text = "Enter name of place..."
            }
            textView.textColor = UIColor(named: "grey")
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor(named: "grey") && !text.isEmpty {
            textView.textColor = UIColor(named: "text-title")
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor(named: "grey") {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
//        self.scrollView.isScrollEnabled = false
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
