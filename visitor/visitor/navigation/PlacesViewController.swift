//
//  PlacesViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 8.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources
import SwiftJWT
import SafariServices

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PlacesCellProtocol {
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    var places: [Place]? = [Place]()
    var onlyFav: Bool? = false
    var typeId: Int?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterBtns: [UIButton]!
    @IBAction func filterClick(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case "All":
            onlyFav = nil
            typeId = nil
        case "Favourites":
            onlyFav = true
            typeId = nil
        case "Parks":
            onlyFav = nil
            typeId = 0
        case "Museums":
            onlyFav = nil
            typeId = 1
        default:
            onlyFav = nil
            typeId = nil
        }
        setFocus(btn_unfocus: button_unfocus, btn_focus: sender)
        reset()
    }
    var button_unfocus = UIButton()
    var searchActive : Bool = false
    var placesFiltered: [Place]? = [Place]()
    @IBOutlet var searchTF: UITextField! {
        didSet {
            searchTF.layer.masksToBounds = true
            searchTF.layer.cornerRadius = 20
            searchTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: searchTF.frame.height))
            searchTF.leftViewMode = .always
            let imageView = UIImageView(image: UIImage(named: "search"))
            imageView.contentMode = .scaleAspectFit
            searchTF.rightView = imageView
            searchTF.rightViewMode = .always
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        setupCustomNavBar()
        if UserDefaults.standard.string(forKey: "userId") != nil {
            getAllPlaces()
        } else {
            getUserId()
        }
        self.tabBarController?.tabBar.layer.borderWidth = 0.50
        self.tabBarController?.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
        setFocus(btn_unfocus: button_unfocus, btn_focus: filterBtns[0])
        self.searchTF.delegate = self
        self.searchTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchTF.resignFirstResponder()
    }
    
    static func getJwtToken() -> String? {
        if let filepath = Bundle.main.path(forResource: "jwt-key", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let test = String(contents.filter { !" \n\t\r".contains($0) })
                let privateKey: Data? = test.data(using: .utf8)
                let jwtSigner = JWTSigner.hs256(key: privateKey!)
                struct MyClaims: Claims {
                }
                let myClaims = MyClaims()
                let myHeader = Header()
                var myJWT = JWT(header: myHeader, claims: myClaims)
                do {
                    let signedJWT = try myJWT.sign(using: jwtSigner)
                    print(signedJWT)
                    return signedJWT
                } catch {
                    print("error")
                }
            } catch {
                
            }
        } else {
            
        }
        return nil
    }
    
    func getUserId() {
        let url = URL(string: BASE_URL + "/api/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        print(jsonResult["id"] as! String)
                        let defaults = UserDefaults.standard
                        defaults.set(jsonResult["id"] as! String, forKey: "userId")
                        self.getAllPlaces()
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
        })
        
        dataTask?.resume()
    }
    
    func getAllPlaces() {
        let userId = UserDefaults.standard.string(forKey: "userId")
        var url = URLComponents(string: BASE_URL + "/api/place/\(userId ?? "userId")")!
        var queryItems = [URLQueryItem]()
        if typeId != nil {
            queryItems.append(URLQueryItem(name: "typeId", value: (typeId?.description ?? "none")))
        }
        if onlyFav != nil {
            queryItems.append(URLQueryItem(name: "onlyFavourites", value: (onlyFav?.description ?? "none")))
        }
        queryItems.append(URLQueryItem(name: "approved", value: "true"))
        url.queryItems = queryItems
        var request = URLRequest(url: url.url!)
        print(String(url.url!.absoluteString))
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                let welcome = try? JSONDecoder().decode(Welcome.self, from: data)
                self.places = welcome?.places
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        })
        
        dataTask?.resume()
    }
    
    func reset() {
        places?.removeAll()
        tableView.reloadData()
        getAllPlaces()
    }
    
    func addRemoveFavourite(id: String?) {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "/api/user/\(userId ?? "userId")/favourites/\(id ?? "placeId")")!
        print(String(url.url!.absoluteString))
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON["message"]!)
                }
            }
        })
        
        dataTask?.resume()
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
        
        //        let btn1 = UIButton(type: .custom)
        //        btn1.setImage(UIImage(named: "near_me"), for: .normal)
        //        btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        //        let item1 = UIBarButtonItem(customView: btn1)
        //        self.navigationItem.leftBarButtonItem = item1
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "profile"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn2.addTarget(self, action: #selector(openProfile(_:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        self.navigationItem.rightBarButtonItem = item2
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 12.0)!]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    func setFocus(btn_unfocus: UIButton, btn_focus: UIButton) {
        btn_unfocus.setTitleColor(UIColor(named: "grey"), for: .normal)
        btn_unfocus.backgroundColor = UIColor(named: "fade-white")
        btn_unfocus.tintColor = UIColor(named: "grey")
        btn_focus.setTitleColor(.white, for: .normal)
        btn_focus.backgroundColor = UIColor(named: "green")
        btn_focus.tintColor = .white
        button_unfocus = btn_focus
    }
    
    @objc func openProfile(_ sender: UIBarButtonItem) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileController") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Table view data source
    
    func openWebsite(url: String!) {
        if let url = URL(string: url) {
            if UIApplication.shared.canOpenURL(url as URL) {
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
            }
        }
    }
    
    func heartTapped(id: Int!, isFav: Bool!) {
        var place = places![id]
        place.isFavourite = isFav
        addRemoveFavourite(id: place.id)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfSections: Int = 0
        
        if searchActive && placesFiltered != nil {
            numOfSections = placesFiltered!.count
        } else if !searchActive && places != nil {
            numOfSections = places!.count
        }
        
        if numOfSections > 0 {
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.numberOfLines = 0
            noDataLabel.text = "No places to show."
            noDataLabel.textColor = UIColor(named: "text-title")
            noDataLabel.font = UIFont(name: "Rubik-Medium", size: 14.0)
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? PlacesTableViewCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        
        if searchActive {
            cell.place = placesFiltered![indexPath.row]
        } else {
            cell.place = places![indexPath.row];
        }
        cell.tableView = tableView
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "planVisitController") as! PlanVisitController
        viewController.place = places![indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let searchText = textField.text
        
        placesFiltered = places!.filter({ (place) -> Bool in
            let placeName: NSString = place.name as NSString
            let range = placeName.range(of: searchText!, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if (placesFiltered!.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
}

protocol PlacesCellProtocol {
    func openWebsite(url: String!)
    func heartTapped(id: Int!, isFav: Bool!)
}
