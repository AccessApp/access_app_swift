//
//  ProfileViewController.swift
//  places
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBAction func saveButton(_ sender: UIButton) {
        UserDefaults.standard.set(textField.text, forKey: "age")
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        textField.text = UserDefaults.standard.string(forKey: "age")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 3
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textField.endEditing(true)
    }
    
}
