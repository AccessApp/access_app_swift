//
//  ProfileViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class ProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var wheelChairAssist: UISwitch!
    @IBOutlet var blindAssist: UISwitch!
    
    @IBAction func saveButton(_ sender: UIButton) {
        UserDefaults.standard.set(textField.text, forKey: "age")
        UserDefaults.standard.set(wheelChairAssist.isOn, forKey: "wheelChairAssist")
        UserDefaults.standard.set(blindAssist.isOn, forKey: "blindAssist")
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        textField.text = UserDefaults.standard.string(forKey: "age")
        wheelChairAssist.isOn = UserDefaults.standard.bool(forKey: "wheelChairAssist")
        blindAssist.isOn = UserDefaults.standard.bool(forKey: "blindAssist")
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
