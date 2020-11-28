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
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    var imgBase64: String?
    var place: Place?
    
    @IBAction func addPlaceClicked(_ sender: UIButton) {
        self.addPlace()
    }
    @IBAction func uploadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var placeNameTV: UITextView! {
        didSet {
            placeNameTV.tag = 1
            placeNameTV.placeholder = "Enter name of place..."
            placeNameTV.layer.masksToBounds = true
            placeNameTV.layer.cornerRadius = 5
            placeNameTV.contentInset.top = 5.0
            placeNameTV.layer.borderWidth = 1
            placeNameTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    @IBOutlet var locationTV: UITextView! {
        didSet {
            locationTV.tag = 2
            locationTV.placeholder = "Enter location..."
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
            descTV.placeholder = "Enter description..."
            descTV.layer.masksToBounds = true
            descTV.layer.cornerRadius = 5
            descTV.layer.borderWidth = 1
            descTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    @IBOutlet var urlTV: UITextView! {
        didSet {
            urlTV.tag = 4
            urlTV.placeholder = "Enter place url..."
            urlTV.layer.masksToBounds = true
            urlTV.layer.cornerRadius = 5
            urlTV.contentInset.top = 5.0
            urlTV.layer.borderWidth = 1
            urlTV.layer.borderColor = UIColor(named: "light-grey")?.cgColor
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var addPlaceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        
        if place != nil {
            self.setupPlaceInfo()
        }
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func setupPlaceInfo() {
        addPlaceButton.setTitle("Save", for: .normal)
        titleLabel.text = "Edit place"
        imageView.downloaded(from: BASE_URL + "get-image/\(place?.id ?? "place id")")
        placeNameTV.placeholder = ""
        placeNameTV.text = place?.name
        locationTV.placeholder = ""
        locationTV.text = place?.location
        descTV.placeholder = ""
        descTV.text = place?.description
        urlTV.placeholder = ""
        urlTV.text = place?.www
    }
    
    func addPlace() {
        guard let image = imgBase64 else {
            alert(title: "Image required", message: "Choose image for the place")
            return
        }
        guard let name = placeNameTV.text else {
            alert(title: "Place name required", message: "Enter name of the place")
            return
        }
        guard let desc = descTV.text else {
            alert(title: "Description required", message: "Enter description of the place")
            return
        }
        guard let location = locationTV.text else {
            alert(title: "Location required", message: "Enter location of the place")
            return
        }
        guard let website = urlTV.text else {
            alert(title: "Website address required", message: "Enter website address of the place")
            return
        }
        self.showLoadingIndicator()
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "add-place/")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        let body: [String : Any] = ["name": name as String, "typeId": 0, "description": desc as String, "www": website as String, "location": location as String, "image": image as String, "userId": (userId ?? "userId")]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            print("REQUEST BODY: \(String(data: request.httpBody!, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!)")
            print("REQUEST HEADER: \(String(describing: request.allHTTPHeaderFields!))")
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON["message"]!)
                }
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            
        })
        
        dataTask?.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

extension AddPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = image
            guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
            imgBase64 = imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
