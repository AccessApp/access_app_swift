//
//  ScanViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 8.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit
import resources
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScannerDelegate {
    
    @IBOutlet var scanView: UIView!
    var scanner: CustomScanner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        
        self.scanner = CustomScanner(withDelegate: self)
        
        guard let scanner = self.scanner else {
            return
        }
        
        scanner.requestCaptureSessionStartRunning()
    }
    
    func setupCustomNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let logo = UIImageView()
        logo.image = UIImage(named: "logo")
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit
        let contentView = UIView()
        self.navigationItem.titleView = contentView
        self.navigationItem.titleView?.addSubview(logo)
        logo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        logo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        self.navigationItem.titleView?.addSubview(logo)
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "near_me"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        //        btn1.addTarget(self, action: #selector(Class.Methodname), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.leftBarButtonItem = item1
        
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "profile"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        btn2.addTarget(self, action: #selector(openProfile(_:)), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        self.navigationItem.rightBarButtonItem = item2
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "Rubik-Regular", size: 12.0)!]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @objc func openProfile(_ sender: UIBarButtonItem) {
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileController") as UIViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Mark - AVFoundation delegate methods
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        guard let scanner = self.scanner else {
            return
        }
        scanner.metadataOutput(output,
                               didOutput: metadataObjects,
                               from: connection)
    }
    
    // Mark - Scanner delegate methods
    func cameraView() -> UIView
    {
        return self.scanView
    }
    
    func delegateViewController() -> UIViewController
    {
        return self
    }
    
    func scanCompleted(withCode code: String)
    {
        print(code)
    }
}
