//
//  PlanVisitCell.swift
//  visitor
//
//  Created by Deyan Marinov on 15.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit

class PlanVisitCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var contentViewCell: UIView! {
        didSet {
            contentViewCell.layer.cornerRadius = 6
            contentViewCell.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var type: UIButton! {
        didSet {
            type.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
            type.layer.masksToBounds = true
            type.layer.cornerRadius = 6
            type.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var fromTo: UILabel!
    
    @IBOutlet weak var capMax: UILabel!
    
    @IBOutlet var check: UIImageView!
    
    @IBOutlet var person: UIImageView!
    
    var slot: Slots.Slot? {
        didSet {
            if let slot = slot {
                if slot.type == "Standard" {
                    type.setTitle("S", for: .normal)
                    type.backgroundColor = UIColor(named: "primary")
                } else {
                    type.setTitle("P", for: .normal)
                    if slot.isPlanned {
                        type.setTitleColor(UIColor(named: "green"), for: .normal)
                        type.backgroundColor = .white
                    } else {
                        type.setTitleColor(.white, for: .normal)
                        type.backgroundColor = UIColor(named: "green")
                    }
                }
                if slot.isPlanned {
                    contentViewCell.backgroundColor = UIColor(named: "green")
                    check.tintColor = .white
                    capMax.textColor = .white
                    fromTo.textColor = .white
                    person.tintColor = .white
                } else {
                    contentViewCell.backgroundColor = UIColor(named: "fade-white")
                    check.tintColor = UIColor(named: "fade-white")
                    capMax.textColor = UIColor(named: "grey")
                    fromTo.textColor = UIColor(named: "grey")
                    person.tintColor = UIColor(named: "grey")
                }
                fromTo.text = "\(slot.from)-\(slot.to)"
                capMax.text = "\(slot.occupiedSlots)/\(slot.maxSlots)"
            }
        }
    }
    
}
