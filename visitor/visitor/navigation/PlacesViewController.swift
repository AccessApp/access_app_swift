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

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlacesCellProtocol {
    
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
    @IBOutlet var searchTF: UITextField! {
        didSet {
            searchTF.layer.masksToBounds = true
            searchTF.layer.cornerRadius = 20
            searchTF.rightViewMode = .always
            searchTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: searchTF.frame.height))
            searchTF.leftViewMode = .always
            let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 17))
            image.image = UIImage(named: "search")
            image.contentMode = .scaleAspectFit
            searchTF.rightView = image
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
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "near_me"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.leftBarButtonItem = item1
        
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
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
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
        return places!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as? PlacesTableViewCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        
        // Put data into the cell
        cell.place = places![indexPath.row]
        cell.tableView = tableView
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "planVisitController") as! PlanVisitController
        viewController.place = places![indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension UIImageView {
    func downloaded(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
}

protocol PlacesCellProtocol {
    func openWebsite(url: String!)
    func heartTapped(id: Int!, isFav: Bool!)
}
