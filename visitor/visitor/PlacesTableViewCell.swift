//
//  PlacesTableViewCell.swift
//  visitor
//
//  Created by Deyan Marinov on 12.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit

class PlacesTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    var delegate: PlacesCellProtocol!
    
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
    
    @IBOutlet weak var placeImage: UIImageView! {
        didSet {
            placeImage.layer.cornerRadius = 5
            placeImage.clipsToBounds = true
        }
    }
    
    var place: Place? {
        didSet {
            if let place = place {
                titleLabel.text = place.name
                desc.text = place.placeDescription
                website.text = place.www
                placeImage.downloaded(from: BASE_URL + "/api/image/\(place.id)")
            }
        }
    }
    
    @objc func tapFunction(_ sender: UITapGestureRecognizer) {
        if let url = place?.www {
            self.delegate.openWebsite(url: url)
        }
    }
    
}
