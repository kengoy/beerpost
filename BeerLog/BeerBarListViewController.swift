//
//  ViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2015/12/28.
//  Copyright © 2015年 dr.sunoo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import QuadratTouch
import GoogleMobileAds

typealias JSONParameters = [String: AnyObject]

class BeerBarListViewController: UIViewController,
  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var session: Session!
    var venueItems : [[String: AnyObject]]?
    
    var refreshObserver: NSObjectProtocol?

    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var cl = CLLocation()

    //var scrollBeginingPoint: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
            action: "onRefresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.estimatedRowHeight = 142
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = BeerLogDifinition.TITLEBAR_COLOR
        let backButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        let client = Client(clientID: BeerLogDifinition.FOURSQUARE_API_CLIENT_ID,
            clientSecret: BeerLogDifinition.FOURSQUARE_API_CLIENT_SECRET,
            redirectURL: BeerLogDifinition.FOURSQUARE_API_REDIRECT_URL)
        let configuration = Configuration(client:client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        session = Session.sharedSession()
        
        let bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - bannerView.frame.height - self.tabBarController!.tabBar.frame.size.height - 63) // To Be Fixed for this magic number
        bannerView.adUnitID = BeerLogDifinition.ADMOB_ID
        bannerView.rootViewController = self
        self.view.addSubview(bannerView)
        let request:GADRequest = GADRequest()
        //request.testDevices = ["206611b1dde66257a63c7909e2b8f026"]
        bannerView.loadRequest(request)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(animated: Bool) {
        // 位置情報取得を禁止している場合
        observers.append(
            nc.addObserverForName(ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    
                    // 位置情報がONになっていないダイアログ表示
                    self.presentViewController(self.ls.locationServiceDisabledAlert,
                        animated: true,
                        completion: nil)
            })
        )
        // 位置情報取得を制限している場合
        observers.append(
            nc.addObserverForName(ls.LSAuthRestrictedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    
                    // 位置情報が制限されているダイアログ表示
                    self.presentViewController(self.ls.locationServiceRestrictedAlert,
                        animated: true,
                        completion: nil)
            })
        )
        // 位置情報取得に失敗した場合
        observers.append(
            nc.addObserverForName(ls.LSDidFailLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    
                    // 位置情報取得に失敗したダイアログ
                    self.presentViewController(self.ls.locationServiceDidFailAlert,
                        animated: true,
                        completion: nil)
            })
        )
        
        // 位置情報を取得した場合
        observers.append(
            nc.addObserverForName(ls.LSDidUpdateLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    
                    if let userInfo = notification.userInfo as? [String: CLLocation] {
                        // userInfoが[String: CLLocation]の形をしている
                        if let clloc = userInfo["location"] {
                            // for debug
                            // print(String("\(clloc.coordinate.latitude)") + "," + String("\(clloc.coordinate.longitude)"))

                            self.cl = clloc
                            
                            var activityIndicator: UIActivityIndicatorView!
                            // loading indicator
                            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                            activityIndicator.frame = CGRectMake(0, 0, 25, 25)
                            activityIndicator.center = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2 , y: UIScreen.mainScreen().bounds.size.height / 2)
                            activityIndicator.hidesWhenStopped = true
                            activityIndicator.startAnimating()
                            self.view.addSubview(activityIndicator)
                            self.loadBeerBarFromFoursquare({ (error) -> Void in
                                activityIndicator.stopAnimating()
                                activityIndicator.removeFromSuperview()
                            })
                        }
                    }
            })
        )
        // 位置情報が利用可能になった場合
        observers.append( 
            nc.addObserverForName(ls.LSAuthorizedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
            })
        )
        
        ls.startUpdatingLocation()
    }

    override func viewWillDisappear(animated: Bool) {
        for observer in observers {
            nc.removeObserver(observer)
        }
        observers = []
    }
    
    /*
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollBeginingPoint = scrollView.contentOffset;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset;
        if scrollBeginingPoint != nil {
            if scrollBeginingPoint.y < currentPoint.y {
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onRefresh(refreshControl: UIRefreshControl){
        refreshControl.beginRefreshing()
        /*
        refreshObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                NSNotificationCenter.defaultCenter().removeObserver(self.refreshObserver!)
                refreshControl.endRefreshing()
        })
        
        yls.loadData(true)
        */
        
        loadBeerBarFromFoursquare { (error) -> Void in
            refreshControl.endRefreshing()
        }

    }

    private func loadBeerBarFromFoursquare(callback: (NSError?) -> Void) {
        var parameters = [Parameter.venuePhotos:"1", Parameter.sortByDistance:"1", Parameter.openNow:"1", Parameter.limit:"50",
            Parameter.categoryId:"56aa371ce4b08b9a8d57356c,4bf58dd8d48988d117941735,4bf58dd8d48988d11d941735,4bf58dd8d48988d11b941735,5370f356bcbc57f1066c94c2"]
        // Foursqure Category ID : ref https://developer.foursquare.com/categorytree
        // Beer Bar : 56aa371ce4b08b9a8d57356c
        // Beer Garden : 4bf58dd8d48988d117941735
        // Sports Bar : 4bf58dd8d48988d11d941735
        // Pub : 4bf58dd8d48988d11b941735
        // Beer Store : 5370f356bcbc57f1066c94c2
        parameters += cl.parameters()
        let searchTask = self.session.venues.explore(parameters) {
            (result) -> Void in
            if let response = result.response {
                // for debug
                //print(response)
                if let groups = response["groups"] as? [[String: AnyObject]]  {
                    var venues = [[String: AnyObject]]()
                    for group in groups {
                        if let items = group["items"] as? [[String: AnyObject]] {
                            venues += items
                        }
                    }
                    
                    self.venueItems = venues
                }
                self.tableView.reloadData()

            } else if let error = result.error where !result.isCancelled() {
                print("explore error:" + "\(error)")
                
                if error.code == -1009 {
                    let alertView = UIAlertController(title: "Error",
                        message: "Network Connection Error",
                        preferredStyle: .Alert)
                    alertView.addAction(
                        UIAlertAction(title: "OK", style: .Default) {
                            action in return
                        }
                    )
                    self.presentViewController(alertView,
                        animated: true, completion: nil)
                }
            }
            callback(result.error)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        searchTask.start()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return self.tableView.estimatedRowHeight
    }

    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let venues = venueItems {
                return venues.count
            }
        }

        // should not come here
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BeerBarListItem", forIndexPath: indexPath)
                as! BeerBarListItemTableViewCell
            let item = self.venueItems![indexPath.row] as JSONParameters!

            if let venue = item["venue"] as? JSONParameters! {
                if let name = venue["name"] as? String {
                    cell.name.text = name
                }
                if let score = venue["rating"] as? Float {
                    cell.score.text = "\(score)"
                }
                if let location = venue["location"] as? JSONParameters! {
                    if let address = location["address"] as? String {
                        cell.address.text = address
                    }
                    if let distance = location["distance"] as? Int {
                        let distanceKm = Float(Int((Float(distance) / 1000) *  10)) / 10.0
                        let distanceMile = Float(Int(distanceKm * 0.62137 * 10)) / 10.0
                        
                        let locale = NSLocale.currentLocale()
                        if let country = locale.objectForKey(NSLocaleCountryCode) as? String {
                            if country == "US" {
                                cell.distance.text = "\(distanceMile) mi"
                            } else {
                                cell.distance.text = "\(distanceKm) km"
                            }
                        }
                    }
                }
                if let photos = venue["featuredPhotos"] as? JSONParameters! {
                    if let items = photos["items"] as? [JSONParameters] {
                        if let item = items.first {
                            let URL = photoURLFromJSONObject(item)
                            if let imageData = session.cachedImageDataForURL(URL)  {
                                cell.photo.image = UIImage(data: imageData)
                            } else {
                                cell.photo.image = nil
                                session.downloadImageAtURL(URL) {
                                    (imageData, error) -> Void in
                                    let cell = tableView.cellForRowAtIndexPath(indexPath) as? BeerBarListItemTableViewCell
                                    if let cell = cell, let imageData = imageData {
                                        let image = UIImage(data: imageData)
                                        cell.photo.image = image
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if let tips = item["tips"] as? [JSONParameters] {
                if let tip = tips.first {
                    if let text = tip["text"] as? String {
                        cell.tipsText.text = text
                    }
                    if let user = tip["user"] as? JSONParameters! {
                        if let photo = user["photo"] as? JSONParameters! {
                            let URL = photoURLFromJSONObject(photo)
                            if let imageData = session.cachedImageDataForURL(URL)  {
                                cell.tipsUserPhoto.image = UIImage(data: imageData)
                            } else {
                                cell.tipsUserPhoto.image = nil
                                session.downloadImageAtURL(URL) {
                                    (imageData, error) -> Void in
                                    let cell = tableView.cellForRowAtIndexPath(indexPath) as? BeerBarListItemTableViewCell
                                    if let cell = cell, let imageData = imageData {
                                        let image = UIImage(data: imageData)
                                        cell.tipsUserPhoto.image = image
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
            }

            cell.cl = cl
            return cell
        }
        // should not come here
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        navigationController?.navigationBarHidden = false

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("PushBeerBarFoursquare", sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushBeerBarFoursquare" {
            let vc = segue.destinationViewController as! BeerBarFoursquareViewController
            if let indexPath = sender as? NSIndexPath {
                vc.venue = self.venueItems![indexPath.row]
                vc.session = session
            }
        }
    }
    
    private func photoURLFromJSONObject(photo: JSONParameters!) -> NSURL {
        let prefix = photo!["prefix"] as! String
        let suffix = photo!["suffix"] as! String
        let URLString = prefix + "100x100" + suffix
        let URL = NSURL(string: URLString)
        return URL!
    }
}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}
