//
//  AddSlotsViewController.swift
//  places
//
//  Created by Deyan Marinov on 9.09.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class AddSlotsViewController: UIViewController {
    
    var place: Place?
    var currentDate: String?
    var currentStartTime: String?
    var currentEndTime: String?
    var currentServerDate: String?
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    var onDoneBlock : ((Bool) -> Void)?
    var datePicker: UIDatePicker!
    var startTimePicker: UIDatePicker!
    var endTimePicker: UIDatePicker!
    var currentTypeButton: UIButton!
    @IBOutlet var priorityButton: UIButton!
    @IBOutlet var standardButton: UIButton! {
        didSet {
            standardButton.backgroundColor = UIColor(named: "light-grey")
            standardButton.setTitleColor(UIColor(named: "grey"), for: .normal)
        }
    }
    @IBOutlet var dateTF: UITextField!
    @IBOutlet var startHourTF: UITextField!
    @IBOutlet var endHourTF: UITextField!
    @IBOutlet var maxVisits: UITextField! {
        didSet {
            maxVisits.keyboardType = .numberPad
        }
    }
    @IBOutlet var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.borderColor = UIColor(named: "primary")?.cgColor
        }
    }
    @IBAction func typeClicked(_ sender: UIButton) {
        swapButtons(sender)
    }
    @IBAction func saveClicked(_ sender: Any) {
        var slot = Slots.Slot()
        if let text = currentTypeButton.titleLabel?.text {
            slot.type = text
        }
        slot.from = "\(currentServerDate ?? "date") \(startHourTF.text ?? "start hour")"
        slot.to = "\(currentServerDate ?? "date") \(endHourTF.text ?? "end hour")"
        if maxVisits.text!.isEmpty || maxVisits.text == "0" {
            alert(title: "Number of visitors required", message: "Enter number of visitors")
            return
        }
        if let maxSlots = maxVisits.text?.int {
            slot.maxSlots = maxSlots
        }
        addSlot(slot)
    }
    @IBAction func closePopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                           target: self,
                                                           action: #selector(self.doneClicked(_:)))

        keyboardDoneButtonView.items = [doneButton]
        maxVisits.inputAccessoryView = keyboardDoneButtonView
        
        currentTypeButton = priorityButton
        setDateString(date: Date())
        setTimeString(time: Date(), textField: startHourTF)
        setTimeString(time: Date(), textField: endHourTF)
        currentDate = dateTF.text
        currentStartTime = startHourTF.text
        currentEndTime = endHourTF.text
        setupDatePicker()
        setupStartTimePicker()
        setupEndTimePicker()
        
    }

    func addSlot(_ slot: Slots.Slot?) {
        var body = [String : Any]()
        let userId = UserDefaults.standard.string(forKey: "userId")
        if let slot = slot {
            body = ["type": slot.type as String, "from": slot.from, "to": slot.to, "maxSlots": slot.maxSlots, "userId": (userId ?? "userId")]
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
    
    func setupDatePicker() {
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)
        dateTF.inputView = datePicker
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.datePickerCancel))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([cancelButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        dateTF.inputAccessoryView = toolBar
    }
    
    func setupStartTimePicker() {
        startTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        startTimePicker.datePickerMode = .time
        let locale: Locale = Locale(identifier: "NL")
        startTimePicker.locale = locale
        startTimePicker.addTarget(self, action: #selector(self.startPickerChanged), for: .allEvents)
        startHourTF.inputView = startTimePicker
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.startPickerDone))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.startTimePickerCancel))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([cancelButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        startHourTF.inputAccessoryView = toolBar
    }
    
    func setupEndTimePicker() {
        endTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200))
        endTimePicker.datePickerMode = .time
        let locale: Locale = Locale(identifier: "NL")
        endTimePicker.locale = locale
        endTimePicker.addTarget(self, action: #selector(self.endPickerChanged), for: .allEvents)
        endHourTF.inputView = endTimePicker
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.endPickerDone))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.endTimePickerCancel))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.setItems([cancelButton, UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        endHourTF.inputAccessoryView = toolBar
    }
    
    @objc func datePickerCancel() {
        dateTF.text = currentDate
        dateTF.resignFirstResponder()
    }
    
    @objc func datePickerDone() {
        currentDate = dateTF.text
        dateTF.resignFirstResponder()
    }

    @objc func dateChanged() {
        self.setDateString(date: datePicker.date)
    }
    
    @objc func startPickerDone() {
        currentStartTime = startHourTF.text
        startHourTF.resignFirstResponder()
    }

    @objc func startPickerChanged() {
        endTimePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 1, to: startTimePicker.date)
        self.setTimeString(time: startTimePicker.date, textField: startHourTF)
    }
    
    @objc func startTimePickerCancel() {
        startHourTF.text = currentStartTime
        startHourTF.resignFirstResponder()
    }
    
    @objc func endPickerDone() {
        currentEndTime = endHourTF.text
        endHourTF.resignFirstResponder()
    }

    @objc func endPickerChanged() {
        self.setTimeString(time: endTimePicker.date, textField: endHourTF)
    }
    
    @objc func endTimePickerCancel() {
        endHourTF.text = currentEndTime
        endHourTF.resignFirstResponder()
    }
    
    func setDateString(date: Date) {
        let calendar = Calendar.current
        let weekFormatter = DateFormatter()
        weekFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let dateComponents = calendar.component(.day, from: date)
        let numberFormatter = NumberFormatter()

        numberFormatter.numberStyle = .ordinal

        let day = numberFormatter.string(from: dateComponents as NSNumber)
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MMMM"

        dateTF.text = "\(weekFormatter.string(from: date)), \(day!) \(dateFormatter.string(from: date))"
        let serverFormatter = DateFormatter()
        serverFormatter.dateFormat = "dd.MM.yyyy"
        currentServerDate = serverFormatter.string(from: date)
    }
    
    func setTimeString(time: Date, textField: UITextField) {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm"

        textField.text = "\(dateFormatter.string(from: time))"
    }
    
    func swapButtons(_ button: UIButton) {
        currentTypeButton = button
        if button.titleLabel?.text == "Standard" {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(named: "primary")
            priorityButton.setTitleColor(UIColor(named: "grey"), for: .normal)
            priorityButton.backgroundColor = UIColor(named: "light-grey")
        } else {
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(named: "green")
            standardButton.setTitleColor(UIColor(named: "grey"), for: .normal)
            standardButton.backgroundColor = UIColor(named: "light-grey")
        }
    }
    
    @objc func doneClicked(_ sender: AnyObject) {
      self.view.endEditing(true)
    }
}
