//
//  ProfileViewController.swift
//  places
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources

class PlaceInfoViewController: UIViewController {

    var place: Place?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar()
    }
    
    func setupCustomNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let logo = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        logo.downloaded(from: BASE_URL + "/api/image/\(place!.id)")
        logo.layer.masksToBounds = false
        logo.layer.cornerRadius = logo.frame.height / 2
        logo.clipsToBounds = true
        logo.contentMode = .scaleAspectFill
        
        let lb = UILabel()
        lb.frame.origin.x = logo.frame.maxX + 10
        lb.text = place?.name
        lb.textColor = UIColor(named: "text-title")
        lb.font = UIFont(name: "Rubik-Bold", size: 16.0)
        lb.sizeToFit()
        lb.center.y = logo.center.y
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: (self.navigationController?.navigationBar.frame.height)!))
        contentView.addSubview(logo)
        contentView.addSubview(lb)
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: (self.navigationController?.navigationBar.frame.height)!))
        mainView.addSubview(contentView)
        self.navigationItem.titleView = mainView
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 12.0)!]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
}
