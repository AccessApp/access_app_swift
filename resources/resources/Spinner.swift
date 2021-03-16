//
//  Spinner.swift
//  resources
//
//  Created by Deyan Marinov on 16.12.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit

open class Spinner {
    
    internal static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .large
    public static var baseBackColor = UIColor.black.withAlphaComponent(0.2)
    public static var baseColor = UIColor.white
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: UIDevice.orientationDidChangeNotification, object: nil)
        if spinner == nil, let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
            .filter({$0.isKeyWindow}).first {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            keyWindow.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
    
    @objc public static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
}
