//
//  VisitCell.swift
//  visitor
//
//  Created by Deyan Marinov on 20.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class VisitCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            // Make it card-like
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

    @IBOutlet var type: UIButton! {
        didSet {
            type.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
            type.layer.masksToBounds = true
            type.layer.cornerRadius = 6
            type.isUserInteractionEnabled = false
        }
    }

    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var startHour: UILabel!
    
    @IBOutlet weak var endHour: UILabel!

    @IBOutlet weak var capMax: UILabel!
    
    @IBOutlet weak var visitCount: UILabel!
    
    var visit: Visits.Visit? {
        didSet {
            if let visit = visit {
                type.setTitle(visit.type, for: .normal)
                if visit.type == "Standard" {
                    type.backgroundColor = UIColor(named: "primary")
                } else {
                    type.backgroundColor = UIColor(named: "green")
                }
                placeName.text = visit.name
                startHour.text = visit.startTime
                endHour.text = visit.endTime
                visitCount.text = String(visit.visitors)
                capMax.text = "\(visit.occupiedSlots)/\(visit.maxSlots)"
            }
        }
    }
    
}
