//
//  PostViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/21.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import QuadratTouch

class PostViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postBeerName: UITextField!
    @IBOutlet weak var postBrewery: UITextField!
    @IBOutlet weak var postCountry: UITextField!
    @IBOutlet weak var postABV: UITextField!
    @IBOutlet weak var postIBU: UITextField!
    @IBOutlet weak var postProfile: UITextField!
    @IBOutlet weak var postNote: UITextView!
    @IBOutlet weak var postCreatedPlace: UITextField!
    @IBOutlet weak var postRate: CosmosView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeAutoCompleteTable: UITableView!
    var venueItems : [[String: AnyObject]]?
    
    var txtActiveView : UITextView?
    var originalOffsetY:CGFloat = 0.0
    
    var beerImage = UIImageView()

    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var cl: CLLocation!
    var session: Session!
    var currentTask: Task?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
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
                            //print("PostViewController : Location")
                            //print(String("\(clloc.coordinate.latitude)") + "," + String("\(clloc.coordinate.longitude)"))
                            
                            self.cl = clloc
                            
                        }
                    }
            })
        )
        ls.startUpdatingLocation()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        for observer in observers {
            nc.removeObserver(observer)
        }
        observers = []

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = Session.sharedSession()

        postImage.layer.cornerRadius = 5.0
        postImage.clipsToBounds = true
        postImage.image = beerImage.image
        
        postBeerName.delegate = self
        postBrewery.delegate = self
        postCountry.delegate = self
        postABV.delegate = self
        postIBU.delegate = self
        postProfile.delegate = self
        postNote.delegate = self
        postCreatedPlace.delegate = self
        
        makeBorderLineOnTextField()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = BeerLogDifinition.TITLEBAR_COLOR

        let accessoryView = UIView(frame: CGRectMake(0, 0, super.view.frame.size.width, 44))
        accessoryView.backgroundColor = UIColor.whiteColor()
        let closeButton = UIButton(frame: CGRectMake(super.view.frame.size.width - 120, 7, 100, 30))
        closeButton.setTitle("Done", forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        closeButton.addTarget(self, action: "onClickCloseButton:", forControlEvents: .TouchUpInside)
        accessoryView.addSubview(closeButton)
        postNote.inputAccessoryView = accessoryView
        postIBU.inputAccessoryView = accessoryView
        postABV.inputAccessoryView = accessoryView
        
        postBeerName.becomeFirstResponder()
        
        self.placeAutoCompleteTable.delegate = self
        self.placeAutoCompleteTable.hidden = true;
        self.placeAutoCompleteTable.estimatedRowHeight = 28
        self.placeAutoCompleteTable.rowHeight = UITableViewAutomaticDimension

    }
    
    private func makeBorderLineOnTextField() {
        let width = CGFloat(0.5)

        let border = CALayer()
        border.borderWidth = width
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: postBeerName.frame.size.height - 5, width:  postBeerName.frame.size.width, height: 0.5)
        postBeerName.layer.addSublayer(border)
        postBeerName.layer.masksToBounds = true

        let border2 = CALayer()
        border2.borderWidth = width
        border2.borderColor = UIColor.darkGrayColor().CGColor
        border2.frame = CGRect(x: 0, y: postBrewery.frame.size.height - 5, width:  postBrewery.frame.size.width, height: 0.5)
        postBrewery.layer.addSublayer(border2)
        postBrewery.layer.masksToBounds = true

        let border3 = CALayer()
        border3.borderWidth = width
        border3.borderColor = UIColor.darkGrayColor().CGColor
        border3.frame = CGRect(x: 0, y: postCountry.frame.size.height - 5, width:  postCountry.frame.size.width, height: 0.5)
        postCountry.layer.addSublayer(border3)
        postCountry.layer.masksToBounds = true

        let border4 = CALayer()
        border4.borderWidth = width
        border4.borderColor = UIColor.darkGrayColor().CGColor
        border4.frame = CGRect(x: 0, y: postIBU.frame.size.height - 5, width:  postIBU.frame.size.width, height: 0.5)
        postIBU.layer.addSublayer(border4)
        postIBU.layer.masksToBounds = true

        let border5 = CALayer()
        border5.borderWidth = width
        border5.borderColor = UIColor.darkGrayColor().CGColor
        border5.frame = CGRect(x: 0, y: postABV.frame.size.height - 5, width:  postABV.frame.size.width, height: 0.5)
        postABV.layer.addSublayer(border5)
        postABV.layer.masksToBounds = true

        let border6 = CALayer()
        border6.borderWidth = width
        border6.borderColor = UIColor.darkGrayColor().CGColor
        border6.frame = CGRect(x: 0, y: postProfile.frame.size.height - 5, width:  postProfile.frame.size.width, height: 0.5)
        postProfile.layer.addSublayer(border6)
        postProfile.layer.masksToBounds = true
        
        let border7 = CALayer()
        border7.borderWidth = width
        border7.borderColor = UIColor.darkGrayColor().CGColor
        border7.frame = CGRect(x: 0, y: postNote.frame.size.height - 35, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border7)
        let border8 = CALayer()
        border8.borderWidth = width
        border8.borderColor = UIColor.darkGrayColor().CGColor
        border8.frame = CGRect(x: 0, y: postNote.frame.size.height - 19, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border8)
        let border9 = CALayer()
        border9.borderWidth = width
        border9.borderColor = UIColor.darkGrayColor().CGColor
        border9.frame = CGRect(x: 0, y: postNote.frame.size.height - 3, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border9)
        let border10 = CALayer()
        border10.borderWidth = width
        border10.borderColor = UIColor.darkGrayColor().CGColor
        border10.frame = CGRect(x: 0, y: postNote.frame.size.height + 13, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border10)
        postNote.layer.masksToBounds = true
        let border11 = CALayer()
        border11.borderWidth = width
        border11.borderColor = UIColor.darkGrayColor().CGColor
        border11.frame = CGRect(x: 0, y: postNote.frame.size.height + 30, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border11)
        postNote.layer.masksToBounds = true
        let border12 = CALayer()
        border12.borderWidth = width
        border12.borderColor = UIColor.darkGrayColor().CGColor
        border12.frame = CGRect(x: 0, y: postNote.frame.size.height + 47, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border12)
        postNote.layer.masksToBounds = true
        let border13 = CALayer()
        border13.borderWidth = width
        border13.borderColor = UIColor.darkGrayColor().CGColor
        border13.frame = CGRect(x: 0, y: postNote.frame.size.height + 64, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border13)
        postNote.layer.masksToBounds = true
        let border14 = CALayer()
        border14.borderWidth = width
        border14.borderColor = UIColor.darkGrayColor().CGColor
        border14.frame = CGRect(x: 0, y: postNote.frame.size.height + 81, width:  postNote.frame.size.width, height: 0.5)
        postNote.layer.addSublayer(border14)
        postNote.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPostBeerImage(image: UIImage) {
        self.beerImage.image = image
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        txtActiveView = textView
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == txtActiveView {
            txtActiveView = nil
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
    
        var txtViewRect: CGRect!

        // ignore in case of editting of other text fields
        if txtActiveView == nil {
            return
        } else {
            txtViewRect = txtActiveView?.frame
        }

        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        originalOffsetY = scrollView.contentOffset.y
        
        let offsetY:CGFloat = CGRectGetMaxY(txtViewRect!) - CGRectGetMinY(keyboardRect)
        let scrollPoint:CGPoint = CGPointMake(0.0, offsetY)
        scrollView.contentOffset = scrollPoint
        
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
  
        // ignore in case of editting of other text fields
        if txtActiveView == nil {
            return
        }

        scrollView.contentOffset.y = 0.0
        let scrollPoint:CGPoint = CGPointMake(0.0, originalOffsetY)
        scrollView.contentOffset = scrollPoint
    }

    func onClickCloseButton(sender: UIButton) {
        postNote.resignFirstResponder()
        postIBU.resignFirstResponder()
        postABV.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.placeAutoCompleteTable.hidden = true
        if textField == postCreatedPlace {
            // for debug
            //print("textField : " + textField.text!)
            
            if self.cl == nil {
                return
            }
            
            searchVenues(nil)            
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == postCreatedPlace {
            // for debug
            //print("textField : " + textField.text!)
            
            if self.cl == nil {
                return true
            }
            
            searchVenues(textField.text!)
        }
        return true
    }
    
    private func searchVenues(keyword: String?) {
        currentTask?.cancel()
        var parameters = [Parameter.sortByDistance:"1", Parameter.openNow:"1", Parameter.limit:"50",
            Parameter.categoryId:"56aa371ce4b08b9a8d57356c,4bf58dd8d48988d117941735,4bf58dd8d48988d11d941735,4bf58dd8d48988d11b941735,5370f356bcbc57f1066c94c2"]
        // Foursqure Category ID : ref https://developer.foursquare.com/categorytree
        // Beer Bar : 56aa371ce4b08b9a8d57356c
        // Beer Garden : 4bf58dd8d48988d117941735
        // Sports Bar : 4bf58dd8d48988d11d941735
        // Pub : 4bf58dd8d48988d11b941735
        // Beer Store : 5370f356bcbc57f1066c94c2
        if keyword != nil {
            parameters += [Parameter.query:keyword!]
        }
        parameters += self.cl.parameters()
        currentTask = session.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response {
                // for debug
                //print("search result")
                //print(response["venues"])
                if let venues = response["venues"] as? [JSONParameters] {
                    // for debug
                    /*
                    for venue in venues {
                        if let name = venue["name"] as? String {
                            print(name)
                        }
                    }
                    */
                    self.venueItems = venues
                    self.placeAutoCompleteTable.hidden = false
                    self.placeAutoCompleteTable.reloadData()
                }
            }
        }
        currentTask?.start()
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {

        let postDBEntry = BeerLogPost(userId: "", createdPlace: postCreatedPlace.text, postImage: UIImageJPEGRepresentation(postImage.image!, 0.2), postBeerName: postBeerName.text, postBreweryName: postBrewery.text, postBreweryCountry: postCountry.text, postABV: Float( postABV.text!), postIBU: Int(postIBU.text!), postProfile: postProfile.text, postScore: Float(postRate.rating), postNote: postNote.text)
        
        let realm = try! Realm()
        try! realm.write() {
            realm.add(postDBEntry)
            print("saved an entry.")
        }
        /* for test print
        for beerlog in realm.objects(BeerLogPost) {
        print("beer name:\((beerlog as BeerLogPost).postBeerName!)")
        }
        */
        
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: BeerLogDifinition.NOTIFICATION_NAME_NEW_LOG_CREATED, object: nil, userInfo:  [BeerLogDifinition.NOTIFICATION_USERINFO_NAME : postDBEntry])
        center.postNotification(notification)

        super.navigationController?.popViewControllerAnimated(true)

    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return self.placeAutoCompleteTable.estimatedRowHeight
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
            let cell = tableView.dequeueReusableCellWithIdentifier("BeerBarNameListItem", forIndexPath: indexPath)
                as! BeerBarNameListItemTableViewCell
            let item = self.venueItems![indexPath.row] as JSONParameters!
            
            if let name = item["name"] as? String {
                cell.beerBarName.text = name
            }
            return cell
        }
        // should not come here
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.placeAutoCompleteTable {
            let item = self.venueItems![indexPath.row] as JSONParameters!
            
            if let name = item["name"] as? String {
                postCreatedPlace.text! = name
            }
            self.placeAutoCompleteTable.hidden = true;
            postCreatedPlace.resignFirstResponder()
        }
    }
}
