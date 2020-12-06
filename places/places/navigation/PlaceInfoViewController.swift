//
//  PlaceInfoViewController.swift
//  places
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources
import SafariServices

class PlaceInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderViewDelegate, PlanVisitDelegate {
    
    var place: Place?
    var items = [ItemHeader]()
    var tempHeaders = [ItemHeader]()
    var tempSlots = [Slots.Slot]()
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    var places: [Place]? = [Place]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editPlace: UIImageView!
    @IBOutlet var globe: UIImageView!
    
    static var slotsCounter = 0
    static var headersCounter = 0
    
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
    
    @IBAction func addSlotsClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "addSlotsVC") as! AddSlotsViewController
        vc.place = place
        vc.modalPresentationStyle = .overCurrentContext
        vc.onDoneBlock = { result in
            self.getSlots()
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func tapFunction(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: place!.www) {
            if UIApplication.shared.canOpenURL(url as URL) {
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
            }
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.sectionHeaderHeight = 55
        tableView?.separatorStyle = .none
        //        tableView?.register(PlanVisitCell.self, forCellReuseIdentifier: PlanVisitCell.identifier)
        tableView?.register(PlanVisitHeaderView.nib, forHeaderFooterViewReuseIdentifier: PlanVisitHeaderView.identifier)
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
            desc.text = place.description
            website.text = place.www
            if place.www.isEmpty {
                globe.isHidden = true
            } else {
                globe.isHidden = false
            }
            placeImage.downloaded(from: BASE_URL + "get-image/\(place.id)")
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        editPlace.isUserInteractionEnabled = true
        editPlace.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPlaceController") as? AddPlaceViewController
        viewController!.place = place
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = items[section]
        
        guard item.isCollapsible else {
            return item.slots.count
        }
        
        if item.isCollapsed {
            return 0
        } else {
            return item.slots.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanVisitCell.identifier, for: indexPath) as? PlanVisitCell else {
            fatalError("No CardTableViewCell for cardCell id")
        }
        cell.slot = item.slots[indexPath.row]
        if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell.indexPath = indexPath
        }
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return !items.isEmpty ? items.count : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlanVisitHeaderView.identifier) as? PlanVisitHeaderView {
            let item = items[section]
            
            headerView.item = item
            headerView.section = section
            headerView.delegate = self
            let backgroundView = UIView(frame: headerView.bounds)
            backgroundView.backgroundColor = .white
            headerView.backgroundView = backgroundView
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "popupVC") as! PopupViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.place = self.place
        let item = Array(items)[indexPath.section]
        vc.slot = item.slots[indexPath.row]
        vc.onDoneBlock = { result in
            self.getSlots()
        }
        print(indexPath)
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteSlotServer(items[indexPath.section].slots[indexPath.row])
            items[indexPath.section].slots.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func getSlots() {
        self.showLoadingIndicator()
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "get-place-slots/\(userId ?? "userId")/\(self.place?.id ?? "placeId")")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                self.items.removeAll()
                let decoder = JSONDecoder()
                do {
                    let schedule = try decoder.decode(Outer.self, from: data)
                    let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(string1)
                    var serverItems = [ItemHeader]()
                    var dateKeys: [String] = []
                    for (name, slots) in schedule.slots.innerArray {
                        let section = ItemHeader.init(sectionTitle: name, isCollapsed: true)
                        section.slots = slots
                        dateKeys.append(name)
                        serverItems.append(section)
                    }
                    self.items = self.sortList(dateKeys, serverItems)
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    
                    //                    self.tableView.beginUpdates()
                    //                    self.tableView.reloadSections([section], with: .fade)
                    //                    self.tableView.endUpdates()
                    
                    self.tableView.reloadData()
                }
            }
            
        })
        
        dataTask?.resume()
    }
    
    func sortList(_ dateKeys: [String], _ serverItems: [ItemHeader]) -> [ItemHeader] {
        var arrayOfDates: [Date] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        for dateString in dateKeys {
            let date = dateFormatter.date(from: dateString)
            if let date = date{
                arrayOfDates.append(date)
            }
        }

        arrayOfDates.sort(by: {$0.timeIntervalSince1970 < $1.timeIntervalSince1970})

        var result: [String] = []

        for date in arrayOfDates{
            result.append(dateFormatter.string(from: date))
        }
        var newItems = [ItemHeader]()
        for date in result {
            let object = serverItems.filter{ $0.sectionTitle == date }.first
            newItems.append(object!)
        }
        return newItems
    }
    
    
    /// Toggle header/section when tapped, expand or collapse
    /// - Parameters:
    ///   - header: The clicked headers
    ///   - section: The header's index
    func toggleSection(header: PlanVisitHeaderView, section: Int) {
        let item = items[section]
        if item.isCollapsible {
            
            // Toggle collapse
            let collapsed = !item.isCollapsed
            item.isCollapsed = collapsed
            
            // Adjust the number of the rows inside the section
            self.tableView?.beginUpdates()
            self.tableView?.reloadSections([section], with: .fade)
            self.tableView?.endUpdates()
        }
    }
    
    /// Adds row from top to bottom when dragging with finger, triggered from UILongPressRecognizer()
    /// - Parameter indexPath: The indexPath of the selected row
    func addRow(indexPath: IndexPath) {
        if PlaceInfoViewController.slotsCounter == -1 {
            PlaceInfoViewController.slotsCounter = 0
        }
        let firstSlot = items[indexPath.section].slots[0]
        let indexValue = indexPath.row + PlaceInfoViewController.slotsCounter
        let lastSlot = items[indexPath.section].slots[indexValue]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let calendar = Calendar.current
        let startDateFirstSlot = dateFormatter.date(from: firstSlot.from)
        PlaceInfoViewController.slotsCounter += 1
        let startDateNewSlot = calendar.date(byAdding: .hour, value: 1, to: dateFormatter.date(from: lastSlot.to)!)
        if startDateFirstSlot == startDateNewSlot {
            return
        }
        var slot: Slots.Slot = Slots.Slot()
        slot.type = lastSlot.type
        slot.from = lastSlot.to
        slot.to = dateFormatter.string(from: startDateNewSlot!)
        slot.occupiedSlots = lastSlot.occupiedSlots
        slot.maxSlots = lastSlot.maxSlots
        slot.friends = lastSlot.friends
        items[indexPath.section].slots.append(slot)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: items[indexPath.section].slots.count - 1, section: indexPath.section)], with: .fade)
        tableView.endUpdates()
        self.tempSlots.append(slot)
    }
    
    /// Removes row from when dragging from bottom to top, triggered from UILongPressRecognizer()
    /// - Parameter indexPath: The indexPath of the selected row
    func removeRow(indexPath: IndexPath) {
        if items[indexPath.section].slots.popLast() == nil {
            return
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: items[indexPath.section].slots.count - 1, section: indexPath.section)], with: .fade)
        tableView.endUpdates()
    }
    
    func addingSlotsEnded(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Adding slots", message: "Are you sure you want to add \(tempSlots.count) \(tempSlots.count == 1 ? "slot" : "slots")?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self]_ in
            addSlotsServer(tempSlots, items[indexPath.section].sectionTitle)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { [self]_ in
            var ipArray = [IndexPath]()
            for i in (indexPath.row + 1...items[indexPath.section].slots.count - 1).reversed() {
                items[indexPath.section].slots.remove(at: i)
                ipArray.append(IndexPath(row: i, section: indexPath.section))
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: ipArray, with: .fade)
            tableView.endUpdates()
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addSlotsServer(_ slots: [Slots.Slot],_ date: String) {
        for i in 0...slots.count - 1 {
            self.addSlotServer(slots[i], date)
        }
    }
    
    func addSlotServer(_ slot: Slots.Slot?,_ date: String) {
        var body = [String : Any]()
        let userId = UserDefaults.standard.string(forKey: "userId")
        if let slot = slot {
            body = ["type": slot.type as String, "from": "\(date) \(slot.from)", "to": "\(date) \(slot.to)", "maxSlots": slot.maxSlots, "userId": (userId ?? "userId")]
        } else {
            return
        }
        let url = URLComponents(string: BASE_URL + "add-slot/\(place?.id ?? "placeId")")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        self.showLoadingIndicator()
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let responseMessage = responseJSON["message"] {
                        print(responseMessage)
                    }
                }
            }
            print("slot added!")
            
        })
        
        dataTask?.resume()
    }
    
    func deleteSlotServer(_ slot: Slots.Slot?) {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "delete-slot/\(userId ?? "userId")/\(slot?.id ?? "slotId")")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        self.showLoadingIndicator()
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let responseMessage = responseJSON["message"] {
                        print(responseMessage)
                    }
                }
            }
        })
        
        dataTask?.resume()
    }
    
    func addHeaderRow(section: Int) {
        if PlaceInfoViewController.headersCounter == -1 {
            PlaceInfoViewController.headersCounter = 0
        }
        
        let firstHeader = items[0]
        let indexValue = section + PlaceInfoViewController.headersCounter
        let lastHeader = items[indexValue]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let calendar = Calendar.current
        let startDateFirstHeader = dateFormatter.date(from: firstHeader.sectionTitle)
        PlaceInfoViewController.headersCounter += 1
        let startDateNewHeader = calendar.date(byAdding: .day, value: 1, to: dateFormatter.date(from: lastHeader.sectionTitle)!)
        if startDateFirstHeader == startDateNewHeader {
            return
        }
        let selectedSection = ItemHeader(sectionTitle: dateFormatter.string(from: startDateNewHeader!), isCollapsed: true)
        selectedSection.slots = items[section].slots
        items.append(selectedSection)
        tableView.beginUpdates()
        self.tableView.insertSections(IndexSet(integer: items.count - 1), with: .fade)
        tableView.endUpdates()
        self.tempHeaders.append(selectedSection)
    }
    
    func addingHeadersEnded(section: Int) {
        let alertController = UIAlertController(title: "Adding days", message: "Are you sure you want to add \(tempHeaders.count) \(tempHeaders.count == 1 ? "day" : "days")?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [self]_ in
            for header in tempHeaders {
                addSlotsServer(header.slots, header.sectionTitle)
            }
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { [self]_ in
            var ipArray = IndexSet()
            for i in (section + 1...items.count - 1).reversed() {
                items.remove(at: i)
                ipArray.insert(i)
            }
            tableView.beginUpdates()
            tableView.deleteSections(ipArray, with: .fade)
            tableView.endUpdates()
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

class ItemHeader: Equatable, Hashable {
    
    var sectionTitle: String = ""
    
    var isCollapsed: Bool
    
    var isCollapsible: Bool {
        return true
    }
    
    var rowCount: Int {
        return 1
    }
    
    var slots = [Slots.Slot]()
    
    init(sectionTitle: String, isCollapsed: Bool) {
        self.sectionTitle = sectionTitle
        self.isCollapsed = isCollapsed
    }
    
    var hashValue: Int {
        return sectionTitle.hashValue
    }
    
    static func == (lhs: ItemHeader, rhs: ItemHeader) -> Bool {
        return lhs.sectionTitle == rhs.sectionTitle && lhs.isCollapsed == rhs.isCollapsed
    }
}

//protocol ProfileViewModelItem {
//    var sectionTitle: String { get }
//    var rowCount: Int { get }
//    var isCollapsible: Bool { get }
//    var isCollapsed: Bool { get set }
//}

//extension ProfileViewModelAttributeItem {
//    var rowCount: Int {
//        return 1
//    }
//
//    var isCollapsible: Bool {
//        return true
//    }
//}

