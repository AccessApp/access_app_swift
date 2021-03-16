//
//  PlanVisitHeaderView.swift
//  places
//
//  Created by Deyan Marinov on 15.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

protocol HeaderViewDelegate: class {
    func toggleSection(header: PlanVisitHeaderView, section: Int)
    func addHeaderRow(section: Int)
    func addingHeadersEnded(section: Int)
}

class PlanVisitHeaderView: UITableViewHeaderFooterView {
    
    var item: ItemHeader? {
        didSet {
            guard let item = item else {
                return
            }
                        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let date = dateFormatter.date(from: item.sectionTitle)
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "EEE"
            let dayInWeek = dateFormatter1.string(from: date!)
            dayLabel.text = "\(dayInWeek.uppercased())"
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MMMM"
            let month = dateFormatter2.string(from: date!)
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date!)
            dateLabel.text = "\(components.day ?? 0)\(Helpers.daySuffix(from: date!)) \(month)"
            
            self.updateBackgroundView()
        }
    }
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backgroundHeaderView: UIView!
    
    var section: Int = 0
    var isLastSection = false
    var initialCenter: CGFloat?
    
    weak var delegate: HeaderViewDelegate?
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateBackgroundView()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(addMoreHeaders(gesture:))))
    }
    
    @objc private func didTapHeader() {
        delegate?.toggleSection(header: self, section: section)
    }
    
    @objc private func addMoreHeaders(gesture: UILongPressGestureRecognizer) {
        if isLastSection {
            if gesture.state == .began {
                guard let view = gesture.view else {
                    return
                }
                initialCenter = view.center.y
                let overlay = UIView(frame: self.backgroundHeaderView.bounds)
                overlay.backgroundColor = UIColor(named: "fade-white")?.withAlphaComponent(0.5)
                overlay.tag = 200
                self.backgroundHeaderView.addSubview(overlay)
            }
            else if gesture.state == .changed {
                
                guard let view = gesture.view else {
                    return
                }
                
                let newCenter = gesture.location(in: view.superview).y
                
                if newCenter - initialCenter! >= 55 {
                    initialCenter! += 55
                    delegate?.addHeaderRow(section: section)
                } else if newCenter - initialCenter! <= -55 {
                    initialCenter! -= 55
//                    delegate?.addHeaderRow(indexPath: indexPath, section: section)
                }
            }
            else if gesture.state == .ended {
                if let view = self.backgroundHeaderView.viewWithTag(200) {
                    view.removeFromSuperview()
                }
                PlaceInfoViewController.headersCounter = -1
                delegate?.addingHeadersEnded(section: section)
            }
        }
    }
    
    func updateBackgroundView() {
        if let item = item, item.isNewlyAdded {
            let overlay = UIView(frame: self.backgroundHeaderView.bounds)
            overlay.backgroundColor = UIColor(named: "fade-white")?.withAlphaComponent(0.5)
            overlay.tag = 200
            self.backgroundHeaderView.addSubview(overlay)
        } else {
            if let view = self.backgroundHeaderView.viewWithTag(200) {
                view.removeFromSuperview()
            }
        }
    }
}

