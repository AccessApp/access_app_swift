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
    var tableView: UITableView?
    
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
    
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var globe: UIImageView!
    @IBOutlet var heartIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let heartTap = UITapGestureRecognizer(target: self, action: #selector(self.heartTapped(_:)))
        heartIcon.isUserInteractionEnabled = true
        heartIcon.addGestureRecognizer(heartTap)
        
        let websiteTap = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction(_:)))
        website.isUserInteractionEnabled = true
        website.addGestureRecognizer(websiteTap)
    }
    
    var place: Place? {
        didSet {
            if let place = place {
                titleLabel.text = place.name
                desc.text = place.placeDescription
                if place.www.isEmpty {
                    globe.isHidden = true
                } else {
                    globe.isHidden = false
                }
                if place.isFavourite {
                    heartIcon.image = UIImage(systemName: "heart.fill")
                    heartIcon.tintColor = UIColor(named: "green")
                } else {
                    heartIcon.image = UIImage(systemName: "heart")
                    heartIcon.tintColor = UIColor(named: "grey")
                }
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
    
    @objc func heartTapped(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: tableView)
        if let path = tableView?.indexPathForRow(at: touch) {
            if heartIcon.tintColor == UIColor(named: "grey") {
                heartIcon.image = UIImage(systemName: "heart.fill")
                heartIcon.tintColor = UIColor(named: "green")
                delegate.heartTapped(id: path.row, isFav: true)
            } else {
                heartIcon.image = UIImage(systemName: "heart")
                heartIcon.tintColor = UIColor(named: "grey")
                delegate.heartTapped(id: path.row, isFav: false)
            }
        }
    }
    
}
