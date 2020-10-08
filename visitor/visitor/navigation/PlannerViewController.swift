//
//  PlannerViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 8.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class PlannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrayJson = Array<[String: [Visits.Visit]]>()
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var upcomingVisitsTable: UILabel!
    @IBOutlet var planVisitBtn: UIButton!
    @IBOutlet var noPlannedVisits: UILabel!
    @IBOutlet var noDataImg: UIImageView!
    @IBOutlet var upcomingVisits: UILabel!
    
    @IBAction func planVisit(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllVisits()
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
//        //        btn1.addTarget(self, action: #selector(Class.Methodname), for: .touchUpInside)
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
    
    @objc func openProfile(_ sender: UIBarButtonItem) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileController") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func getAllVisits() {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "/api/user/\(userId ?? "userId")/visits")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                
                let schedule = try? JSONDecoder().decode(VisitResponse.self, from: data)
                self.arrayJson = Array(arrayLiteral: (schedule?.visits.innerArray)!)
                print(self.arrayJson[0].values)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        })
        
        dataTask?.resume()
    }
    
    func updateView(isTableHidden: Bool) {
        upcomingVisits.isHidden = !isTableHidden
        noDataImg.isHidden = !isTableHidden
        noPlannedVisits.isHidden = !isTableHidden
        planVisitBtn.isHidden = !isTableHidden
        upcomingVisitsTable.isHidden = isTableHidden
        tableView.isHidden = isTableHidden
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: section)
        let s = arrayJson[0].keys[index]
        return arrayJson[0][s]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "visitCell", for: indexPath) as? VisitCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: indexPath.section)
        let s = arrayJson[0].keys[index]
        cell.visit = arrayJson[0][s]![indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let number = !arrayJson.isEmpty ? arrayJson[0].count : 0
        if number == 0 {
            self.updateView(isTableHidden: true)
        } else {
            self.updateView(isTableHidden: false)
        }
        return number
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
        let index = arrayJson[0].index(arrayJson[0].startIndex, offsetBy: indexPath.section)
        let s = arrayJson[0].keys[index]
        vc.visit = arrayJson[0][s]![indexPath.row]
        vc.onDoneBlock = { result in
            self.getAllVisits()
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
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
