//
//  PlanVisitCell.swift
//  places
//
//  Created by Deyan Marinov on 15.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

protocol PlanVisitDelegate: class {
    func addRow(indexPath: IndexPath)
    func removeRow(indexPath: IndexPath)
    func addingSlotsEnded(indexPath: IndexPath)
}

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
    
    var initialCenter: CGFloat?
    
    weak var delegate: PlanVisitDelegate?
    
    var indexPath: IndexPath?
    
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

                self.updateBackgroundView()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateBackgroundView()
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(addMoreCells(gesture:))))
    }
    
    @objc private func addMoreCells(gesture: UILongPressGestureRecognizer) {
        if let indexPath = self.indexPath {
            if gesture.state == .began {
                guard let view = gesture.view else {
                    return
                }
                initialCenter = view.center.y
                let overlay = UIView(frame: self.contentViewCell.bounds)
                overlay.backgroundColor = UIColor(named: "fade-white")?.withAlphaComponent(0.5)
                overlay.tag = 200
                self.contentViewCell.addSubview(overlay)
            }
            else if gesture.state == .changed {
                
                guard let view = gesture.view else {
                    return
                }
                
                let newCenter = gesture.location(in: view.superview).y
                
                if newCenter - initialCenter! >= 48 {
                    initialCenter! += 48
                    delegate?.addRow(indexPath: indexPath)
                } else if newCenter - initialCenter! <= -48 {
                    initialCenter! -= 48
                    delegate?.removeRow(indexPath: indexPath)
                }
                print(initialCenter)
                print(newCenter)
            }
            else if gesture.state == .ended {
                if let view = self.contentViewCell.viewWithTag(200) {
                    view.removeFromSuperview()
                }
                PlaceInfoViewController.slotsCounter = -1
                delegate?.addingSlotsEnded(indexPath: indexPath)
            }
        }
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func updateBackgroundView() {
//        if  {
//            let overlay = UIView(frame: self.contentView.bounds)
//            overlay.backgroundColor = UIColor(named: "fade-white")?.withAlphaComponent(0.5)
//            overlay.tag = 200
//            self.contentView.addSubview(overlay)
//        } else {
//            if let view = self.contentView.viewWithTag(200) {
//                view.removeFromSuperview()
//            }
//        }
    }
}

