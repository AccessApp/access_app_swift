//
//  OnboardViewController.swift
//  visitor
//
//  Created by Deyan Marinov on 20.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController, UIScrollViewDelegate {
    
    var movies: [String] = ["page1","page1","page1"]
    let texts: [String] = ["Stay home", "And office", "And stay healthy"]
    var frame = CGRect.zero
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBAction func getStarted(_ sender: UIButton) {
        if let tabbar = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBar") as? UITabBarController) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = tabbar
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = movies.count
        pageControl.addTarget(self, action: #selector(self.changePage(_:)), for: UIControl.Event.valueChanged)
        
        setupScreens()
    }
    
    func setupScreens() {
        for index in 0..<movies.count {
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = CGSize(width: self.scrollView.frame.size.width, height: 45)
            
            let imgView = UIImageView(frame: frame)
            imgView.contentMode = .scaleAspectFit
            imgView.image = UIImage(named: movies[index])
            
            let text = UILabel(frame: CGRect(x: self.scrollView.frame.size.width * CGFloat(index), y: imgView.frame.size.height + 20, width: self.scrollView.frame.width, height: 20))
            text.text = texts[index]
            text.textAlignment = .center
            text.font = UIFont(name: "Rubik-Regular", size: 14.0)
            text.textColor = UIColor(named: "grey")
            
            self.scrollView.addSubview(text)
            self.scrollView.addSubview(imgView)
        }
        
        scrollView.contentSize = CGSize(width: (self.scrollView.frame.size.width * CGFloat(movies.count)), height: scrollView.frame.size.height)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func changePage(_ sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
}
