//
//  BeerBarFoursquareViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/02/14.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit

import QuadratTouch

class BeerBarFoursquareViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    private var activityIndicator: UIActivityIndicatorView!
    var scrollBeginingPoint: CGPoint!

    var session: Session!
    var venue : [String: AnyObject]?
    override func viewDidLoad() {
        if let venueKey = venue!["venue"] as? JSONParameters! {
            if let id = venueKey["id"] {
                
                let task = self.session.venues.get(String(id)) {
                    (result) -> Void in
                    if let response = result.response {
                        // for debug
                        //print(response)
                        if let venue = response["venue"] as? JSONParameters! {
                            if let canonicalUrl = venue["canonicalUrl"] as? String! {
                                let url: NSURL = NSURL(string: canonicalUrl)!
                                let request: NSURLRequest = NSURLRequest(URL: url)
                                self.webView.delegate = self
                                self.webView.loadRequest(request)
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                            }
                        }
                    } else {
                        print("enues.get error.")
                        if let error = result.error {
                            print(error)
                        }
                    }
                }
                task.start()
                
            }
            
            // loading indicator
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRectMake(0, 0, 250, 250)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        }
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = BeerLogDifinition.TITLEBAR_COLOR
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let indicator = activityIndicator {
            if indicator.isAnimating() {
                indicator.stopAnimating()
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
