//
//  PopupViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 16.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    var slot: Slots.Slot?
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
    
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var fromHour: UILabel!
    @IBOutlet var toHour: UILabel!
    @IBOutlet var placeName: UILabel!
    @IBOutlet var visitorsCount: UILabel!
    
    @IBAction func closePopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: UIButton) {
        savePlan()
    }
    
    @IBAction func dayClick(_ sender: UIButton) {
        setFocus(btn_unfocus: button_unfocus!, btn_focus: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button_unfocus = buttons[0]
        setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[0])
        
        fromHour.text = slot?.from
        toHour.text = slot?.to
        placeName.text = place?.name
        typeButton.setTitle(slot?.type, for: .normal)
        if slot?.type == "Standard" {
            typeButton.backgroundColor = UIColor(named: "primary")
        } else {
            typeButton.backgroundColor = UIColor(named: "green")
        }
        visitorsCount.text = "\(slot?.occupiedSlots ?? 0)/\(slot?.maxSlots ?? 0)"
        if slot!.friends > 0 {
            setFocus(btn_unfocus: button_unfocus!, btn_focus: buttons[slot!.friends - 1])
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
        let url = URLComponents(string: BASE_URL + "/api/user/\(userId ?? "userId")/visit")!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        var body = Dictionary<String, String>()
        body["slotId"] = slot?.id
        body["visitors"] = button_unfocus?.title(for: .normal)
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        if let token = PlacesViewController.getJwtToken() {
            let headerValue = "Bearer \(token)"
            request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        }
        
        dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                print(data)
            }
            
        })
        
        dataTask?.resume()
    }
    
}
