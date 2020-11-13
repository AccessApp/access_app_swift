//
//  PopupViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 16.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class PopupViewController: UIViewController {
    
    @IBOutlet var popupViewConstraint: NSLayoutConstraint!
    
    var slot: Slots.Slot?
    var visit: Visits.Visit?
    var place: Place?
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    
    @IBOutlet var buttons: [UIButton]!
    var button_unfocus: UIButton?
    
    @IBOutlet var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.borderColor = UIColor(named: "primary")?.cgColor
        }
    }
    
    var onDoneBlock : ((Bool) -> Void)?
    
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var fromHour: UILabel!
    @IBOutlet var toHour: UILabel!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var visitorsCount: UILabel!
    @IBOutlet var removeVisitBtn: UIButton!
    
    @IBAction func closePopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: UIButton) {
        savePlan()
    }
    
    @IBAction func dayClick(_ sender: UIButton) {
        setFocus(btn_unfocus: button_unfocus!, btn_focus: sender)
    }
    @IBAction func removeVisit(_ sender: UIButton) {
        removeVisit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let slot = slot {
            
            if slot.isPlanned {
                removeVisitBtn.isHidden = false
                popupViewConstraint.constant += 54.5 // the height of button
            }
            
            button_unfocus = buttons[0]
            setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[0])
            
            fromHour.text = slot.from
            toHour.text = slot.to
            placeName.text = place?.name
            typeButton.setTitle(slot.type, for: .normal)
            if slot.type == "Standard" {
                typeButton.backgroundColor = UIColor(named: "primary")
            } else {
                typeButton.backgroundColor = UIColor(named: "green")
            }
            visitorsCount.text = "\(slot.occupiedSlots)/\(slot.maxSlots)"
            if slot.friends > 0 {
                setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[slot.friends - 1])
            }
        }
        
        if let visit = visit {
            removeVisitBtn.isHidden = false
            popupViewConstraint.constant += 54.5
            
            button_unfocus = buttons[0]
            setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[0])
            
            fromHour.text = visit.startTime
            toHour.text = visit.endTime
            placeName.text = visit.name
            typeButton.setTitle(visit.type, for: .normal)
            if visit.type == "Standard" {
                typeButton.backgroundColor = UIColor(named: "primary")
            } else {
                typeButton.backgroundColor = UIColor(named: "green")
            }
            visitorsCount.text = "\(visit.occupiedSlots)/\(visit.maxSlots)"
            if visit.visitors > 0 {
                setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[visit.visitors - 1])
            }
        }
        
    }
    
    func setFocus(btn_unfocus: UIButton, btn_focus: UIButton) {
        btn_unfocus.setTitleColor(UIColor(named: "grey"), for: .normal)
        btn_unfocus.backgroundColor = UIColor(named: "fade-white")
        btn_focus.setTitleColor(.white, for: .normal)
        btn_focus.backgroundColor = UIColor(named: "primary")
        button_unfocus = btn_focus
    }
    
    func savePlan() {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let url = URLComponents(string: BASE_URL + "visit")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        var body = [String : Any]()
        if slot != nil {
            body = ["slotId": slot!.id as String, "visitors": Int((button_unfocus?.title(for: .normal))!)!, "userId": (userId ?? "userId")]
        } else if visit != nil {
            body = ["slotId": visit!.slotId as String, "visitors": Int((button_unfocus?.title(for: .normal))!)!, "userId": (userId ?? "userId")]
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            //            print("REQUEST BODY: \(String(data: request.httpBody!, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!)")
            //            print("REQUEST HEADER: \(String(describing: request.allHTTPHeaderFields!))")
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON["message"]!)
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    self.onDoneBlock!(true)
                })
            }
            
        })
        
        dataTask?.resume()
    }
    
    func removeVisit() {
        let userId = UserDefaults.standard.string(forKey: "userId")
        let id = slot?.id != nil ? slot?.id : visit?.slotId != nil ? visit?.slotId : "slotId"
        let url = URLComponents(string: BASE_URL + "delete-booking/\(userId ?? "userId")/\(id ?? "slotId")")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "DELETE"
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            //            print("REQUEST BODY: \(String(data: request.httpBody!, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!)")
            //            print("REQUEST HEADER: \(String(describing: request.allHTTPHeaderFields!))")
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204, let data = data {
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON["message"]!)
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                    self.onDoneBlock!(true)
                })
            }
            
        })
        
        dataTask?.resume()
    }
}
