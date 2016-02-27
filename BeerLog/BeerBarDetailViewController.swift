//
//  BeerBarDetailViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/07.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import MapKit

import QuadratTouch

class BeerBarDetailViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var map: MKMapView!

    var session: Session!

    var shop = Shop()
    var venue : [String: AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        if let url = shop.photoUrl {
            photo.sd_setImageWithURL(NSURL(string: url),
                placeholderImage: UIImage(named: "loading"));
        } else {
            photo.image = UIImage(named: "loading")
        }
        name.text = shop.name
        tel.text = shop.tel
        address.text = shop.address
        */
        
        print("viewDidLoad")
        print(venue)
        if let venueKey = venue!["venue"] as? JSONParameters! {
            if let id = venueKey["id"] {
                print("id")
                print(id)
                
                let task = self.session.venues.get(String(id)) {
                    (result) -> Void in
                    if let response = result.response {
                        print(response)
                        if let venue = response["venue"] as? JSONParameters! {
                            if let canonicalUrl = venue["canonicalUrl"] as? String! {
                                print("canonicalUrl")
                                print(canonicalUrl)
                                let myWebView : UIWebView = UIWebView()
                                myWebView.delegate = self
                                myWebView.frame = self.view.bounds
                                self.view.addSubview(myWebView)
                                let url: NSURL = NSURL(string: canonicalUrl)!
                                let request: NSURLRequest = NSURLRequest(URL: url)
                                myWebView.loadRequest(request)
                            }
                            
                            if let shortUrl = venue["shortUrl"] as? String! {
                                print("shortUrl")
                                print(shortUrl)
                            }
                        }
                    } else {
                        // Show error.
                    }
                }
                task.start()
            }
            if let nameKey = venueKey["name"] as? String {
                self.name.text = nameKey
            }
            if let locationKey = venueKey["location"] as? JSONParameters! {
                if let addressKey = locationKey["formattedAddress"] as? String! {
                    self.address.text = addressKey
                }
            }
        }
        

        // map
        /*
        if let lat = shop.lat {
            if let lon = shop.lon {
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
            }
        }
        */
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "E78534")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.scrollView.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.scrollView.delegate = nil
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(
            CGSizeMake(name.frame.size.width, CGFloat.max))
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(
            CGSizeMake(address.frame.size.width, CGFloat.max))
        addressContainerHeight.constant = addressFrame.height
    }

    // MARK: - IBAction
    @IBAction func telTapped(sender: UIButton) {
        print("telTapped")
        if let tel = shop.tel {
            let url = NSURL(string: "tel:\(tel)")
            if (url == nil) { return }
            
            if !UIApplication.sharedApplication().canOpenURL(url!) {
                let alert = UIAlertController(title: "Could not make a phone call",
                message: "This device does not have phone function.",
                preferredStyle: .Alert)
                alert.addAction(
                    UIAlertAction(title: "OK", style: .Default, handler: nil)
                )
                presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            if let name = shop.name {
                let alert = UIAlertController(title: name, message: "Call \(name)?", preferredStyle: .Alert)
                alert.addAction(
                    UIAlertAction(title: "Call", style: .Destructive, handler: {
                        action in
                        UIApplication.sharedApplication().openURL(url!)
                        return
                        })
                )
                alert.addAction(
                    UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                )
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }


    @IBAction func addressTapped(sender: UIButton) {
        print("addressTapped")
        performSegueWithIdentifier("PushMapDetail", sender: nil)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destinationViewController as! BeerBarMapDetailViewController
            vc.shop = shop
        }
    }

}
