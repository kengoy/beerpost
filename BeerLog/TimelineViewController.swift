//
//  TimelineViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/15.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class TimelineViewController: UIViewController, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate {

    @IBOutlet weak var tableView: UITableView!
//    var scrollBeginingPoint: CGPoint!

    var post: [BeerLogPost] = Array<BeerLogPost>()
    let ipc = UIImagePickerController()
    var postImage = UIImage()    
    
    private var newButton: ActionButton!
    
    let ud = NSUserDefaults.standardUserDefaults()
    var isNewLogInserted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension

        let nib = UINib(nibName: "TimelineTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "beerLogPostCell")
        tableView.allowsSelection = false
        navigationItem.rightBarButtonItem = editButtonItem()

        createNewButton()
        
        ipc.delegate = self
        ipc.allowsEditing = true
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = BeerLogDifinition.TITLEBAR_COLOR

        let config = Realm.Configuration(
            schemaVersion: 1,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    migration.enumerate(BeerLogPost.className()) { oldObject, newObject in
                        newObject!["id"] = ""
                        newObject!["userId"] = ""
                        newObject!["numberOfLikes"] = 0
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        for beerlog in realm.objects(BeerLogPost).sorted("createdDate", ascending: false) {
            post.append(beerlog)
            //            print("beer name:\((beerlog as BeerLogPost).postBeerName!)")
        }

        if post.count > 1 {
            let bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - bannerView.frame.height - self.tabBarController!.tabBar.frame.size.height - 63) // To Be Fixed for this magic number
            bannerView.adUnitID = BeerLogDifinition.ADMOB_ID
            bannerView.rootViewController = self
            self.view.addSubview(bannerView)
            let request:GADRequest = GADRequest()
            //request.testDevices = ["206611b1dde66257a63c7909e2b8f026"]
            bannerView.loadRequest(request)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let nc = NSNotificationCenter.defaultCenter()
        let que = NSOperationQueue.mainQueue()
        
        nc.addObserverForName(BeerLogDifinition.NOTIFICATION_NAME_NEW_LOG_CREATED, object: nil, queue: que) { (Notification) -> Void in
            if let newLog = Notification.userInfo![BeerLogDifinition.NOTIFICATION_USERINFO_NAME] as? BeerLogPost {
                if self.isLogDisplayed(newLog) == false {
                    self.post.insert(newLog, atIndex: 0)
                    self.tableView.reloadData()
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                    self.isNewLogInserted = true
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidAppear(animated: Bool) {
        if isNewLogInserted == true {
            if post.count % 3 == 2 && !self.ud.boolForKey("reviewed") {
                let alertController = UIAlertController(
                    title: "Cheers!",
                    message: "Thank you for using BeerPost. Could you review this app?",
                    preferredStyle: .Alert)
                
                let reviewAction = UIAlertAction(title: "Review Now", style: .Default) {
                    action in
                    let url = NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1086445109")
                    UIApplication.sharedApplication().openURL(url!)
                    self.ud.setObject(true, forKey: "reviewed")
                }
                let yetAction = UIAlertAction(title: "Not Now", style: .Default) {
                    action in
                    self.ud.setObject(false, forKey: "reviewed")
                }
                let neverAction = UIAlertAction(title: "NEVER", style: .Cancel) {
                    action in
                    self.ud.setObject(true, forKey: "reviewed")
                }
                
                alertController.addAction(reviewAction)
                alertController.addAction(yetAction)
                alertController.addAction(neverAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            isNewLogInserted = false
        }
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.editing = editing
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let realm = try! Realm()
        for beerlog in realm.objects(BeerLogPost) {
            if beerlog == post[indexPath.row] {
                realm.beginWrite()
                realm.delete(beerlog)
                try! realm.commitWrite()
                break
            }
        }
        post.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row, inSection: 0)],
            withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    private func isLogDisplayed(newLog: BeerLogPost) -> Bool {
        for log in post {
            if log.createdDate == newLog.createdDate {
                return true
            }
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func createNewButton() {
        newButton = ActionButton(attachedToView: self.view, items: [])
        newButton.action = { button in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                alert.addAction(
                    UIAlertAction(title: "Take a photo", style: .Default, handler: {
                    action in
                    self.ipc.sourceType = .Camera
                    self.presentViewController(self.ipc, animated: true, completion: nil)
                })
                )
            }
            alert.addAction(
                UIAlertAction(title: "Select a photo", style: .Default, handler: {
                    action in
                    self.ipc.sourceType = .PhotoLibrary
                    self.presentViewController(self.ipc, animated: true, completion: nil)
                })
            )
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    action in
                })
            )
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        newButton.backgroundColor = UIColor.blackColor()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        ipc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        ipc.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.postImage = image
        }
        self.performSegueWithIdentifier("PushPost", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let postVc: PostViewController = segue.destinationViewController as! PostViewController
        postVc.setPostBeerImage(self.postImage)
    }
    
    func adViewDidReceiveAd(adView: GADBannerView){
        print("adViewDidReceiveAd:\(adView)")
    }
    func adView(adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError){
        print("adView error:\(error)")
    }
    func adViewWillPresentScreen(adView: GADBannerView){
        print("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(adView: GADBannerView){
        print("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(adView: GADBannerView){
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(adView: GADBannerView){
        print("adViewWillLeaveApplication")
    }
}



extension TimelineViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("beerLogPostCell", forIndexPath: indexPath) as! TimelineTableViewCell
        cell.post = post[indexPath.row]
        return cell
    }
}