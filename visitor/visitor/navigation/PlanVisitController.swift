//
//  PlanVisitController.swift
//  visitor
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources
import SafariServices

class PlanVisitController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var place: Place?
    var arrayJson = Array<[String: [Slots.Slot]]>()
    let data = [[0, 1, 2], [3, 4, 5], [6, 7], [12, 10], [1, 8], [44, 30, 8]]
    let jsonString = """
    {
      "slots": {
        "02.06.2020": [
          {
            "id": "slot_id_0_1",
            "type": "Standard",
            "from": "10:00",
            "to": "11:00",
            "occupiedSlots": 0,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          },
          {
            "id": "slot_id_1_1",
            "type": "Priority",
            "from": "11:00",
            "to": "12:00",
            "occupiedSlots": 5,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          },
          {
            "id": "slot_id_2_1",
            "type": "Priority",
            "from": "12:00",
            "to": "13:00",
            "occupiedSlots": 1,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          },
          {
            "id": "slot_id_3_1",
            "type": "Standard",
            "from": "13:00",
            "to": "14:00",
            "occupiedSlots": 2,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          },
          {
            "id": "slot_id_4_1",
            "type": "Priority",
            "from": "14:00",
            "to": "15:00",
            "occupiedSlots": 3,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          },
          {
            "id": "slot_id_5_1",
            "type": "Priority",
            "from": "15:00",
            "to": "16:00",
            "occupiedSlots": 0,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          }
        ],
        "02.06.2021": [
          {
            "id": "slot_id_0_1",
            "type": "Standard",
            "from": "10:00",
            "to": "11:00",
            "occupiedSlots": 0,
            "maxSlots": 20,
            "isPlanned": false,
            "friends": 0
          }
        ]
      }
    }
    """
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    var places: [Place]? = [Place]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var placeInfo: UIImageView!
    @IBOutlet var globe: UIImageView!
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowRadius = 10
            containerView.layer.shadowColor = UIColor(named: "shadow")!.withAlphaComponent(0.14).cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
    }
    
    @IBOutlet weak var clippingView: UIView! {
        didSet {
            clippingView.layer.cornerRadius = 10
            clippingView.backgroundColor = .white
            clippingView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var desc: UITextView! {
        didSet {
            let padding = desc.textContainer.lineFragmentPadding
            desc.textContainerInset =  UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        }
    }
    
    @IBOutlet weak var website: UILabel! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction(_:)))
            website.isUserInteractionEnabled = true
            website.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var placeImage: UIImageView!
    
    
    @objc func tapFunction(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: place!.www) {
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCustomNavBar()
        getSlots()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceCard()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
        
//        let jsonData = Data(jsonString.utf8)
//        let schedule = try? JSONDecoder().decode(Outer.self, from: jsonData)
//        arrayJson = Array(arrayLiteral: (schedule?.slots.innerArray)!)
//        print(arrayJson[0].values)
//        self.tableView.reloadData()

    }
    
    func setupCustomNavBar() {
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
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "profile"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn2.addTarget(self, action: #selector(openProfile(_:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        self.navigationItem.rightBarButtonItem = item2
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 12.0)!]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)

    }
    
    @objc func openProfile(_ sender: UIBarButtonItem) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileController") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupPlaceCard() {
        if let place = place {
            titleLabel.text = place.name
            desc.text = place.placeDescription
            website.text = place.www
            if place.www.isEmpty {
                globe.isHidden = true
            } else {
                globe.isHidden = false
            }
            placeImage.downloaded(from: BASE_URL + "/api/image/\(place.id)")
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        placeInfo.isUserInteractionEnabled = true
        placeInfo.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "placeInfoVC") as! PlaceInfoViewController
        viewController.place = place
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: section)
        let s = arrayJson[0].keys[index]
        return arrayJson[0][s]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath) as? PlanVisitCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: indexPath.section)
        let s = arrayJson[0].keys[index]
        cell.slot = arrayJson[0][s]![indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return !arrayJson.isEmpty ? arrayJson[0].count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? PlanVisitHeaderCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: section)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = arrayJson[0].keys[index]
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "EEE"
        let dayInWeek = dateFormatter1.string(from: date)
        cell.day.text = "\(dayInWeek.uppercased())"
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MMMM"
        let month = dateFormatter2.string(from: date)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        cell.date.text = "\(components.day ?? 0)\(daySuffix(from: date)) \(month)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "popupVC") as! PopupViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.place = self.place
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: indexPath.section)
        let s = arrayJson[0].keys[index]
        vc.slot = arrayJson[0][s]![indexPath.row]
        vc.onDoneBlock = { result in
            self.getSlots()
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func getSlots() {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "/api/place/\(userId ?? "userId")/\(self.place?.id ?? "placeId")")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                
                let schedule = try? JSONDecoder().decode(Outer.self, from: data)
                self.arrayJson = Array(arrayLiteral: (schedule?.slots.innerArray)!)
                print(self.arrayJson[0].values)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
//                let welcome = try? JSONDecoder().decode(Welcome.self, from: data)
//                self.places = welcome?.places
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
            
        })
        
        dataTask?.resume()
    }
    
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
