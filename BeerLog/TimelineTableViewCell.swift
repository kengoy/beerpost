//
//  TimelineTableViewCell.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/15.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {

    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var createdPlace: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var breweryName: UILabel!
    @IBOutlet weak var breweryCountry: UILabel!
    @IBOutlet weak var abv: UILabel!
    @IBOutlet weak var ibu: UILabel!
    @IBOutlet weak var profile: UILabel!
    @IBOutlet weak var score: CosmosView!
    @IBOutlet weak var note: UITextView!

    var post: BeerLogPost! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // make image round
        photo.layer.cornerRadius = 5.0
        photo.clipsToBounds = true
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let currentDate = NSDate()
        if calendar.isDate(currentDate, equalToDate: post.createdDate, toUnitGranularity: NSCalendarUnit.Year)
            && calendar.isDate(currentDate, equalToDate: post.createdDate, toUnitGranularity: NSCalendarUnit.Month)
            && calendar.isDate(currentDate, equalToDate: post.createdDate, toUnitGranularity: NSCalendarUnit.Day)
        {
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateStyle = .NoStyle
            timeFormatter.timeStyle = .ShortStyle
            createdDate.text! = timeFormatter.stringFromDate(post.createdDate)
        } else {
            createdDate.text! = NSDate.shortStringFromDate(post.createdDate)
        }

        createdPlace.text! = post.createdPlace
        photo.image = UIImage(data: post.postImage)
        beerName.text! = post.postBeerName
        breweryName.text! = post.postBreweryName
        breweryCountry.text! = post.postBreweryCountry
        if let abvValue = post.postABV.value {
            abv.text! = String("\(abvValue)")
        } else {
            abv.text! = ""
        }
        if let ibuValue = post.postIBU.value {
            ibu.text! = String("\(ibuValue)")
        } else {
            ibu.text! = ""
        }
        profile.text! = post.postProfile
        if let rating = post.postScore.value {
            score.rating = Double(rating)
        } else {
            score.rating = 0
        }
        score.settings.updateOnTouch = false
        note.text! = post.postNote
        note.editable = false
        
        makeBorderLineOnTextField()
    }
    
    private func makeBorderLineOnTextField() {
        let width = CGFloat(0.5)
        
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: beerName.frame.size.height - 1, width: beerName.frame.size.width, height: 0.5)
        beerName.layer.addSublayer(border)
        beerName.layer.masksToBounds = true
        
        let border2 = CALayer()
        border2.borderWidth = width
        border2.borderColor = UIColor.darkGrayColor().CGColor
        border2.frame = CGRect(x: 0, y: breweryName.frame.size.height - 1, width:  breweryName.frame.size.width, height: 0.5)
        breweryName.layer.addSublayer(border2)
        breweryName.layer.masksToBounds = true
        
        let border3 = CALayer()
        border3.borderWidth = width
        border3.borderColor = UIColor.darkGrayColor().CGColor
        border3.frame = CGRect(x: 0, y: breweryCountry.frame.size.height - 1, width:  breweryCountry.frame.size.width, height: 0.5)
        breweryCountry.layer.addSublayer(border3)
        breweryCountry.layer.masksToBounds = true
        
        let border4 = CALayer()
        border4.borderWidth = width
        border4.borderColor = UIColor.darkGrayColor().CGColor
        border4.frame = CGRect(x: 0, y: abv.frame.size.height - 1, width:  abv.frame.size.width, height: 0.5)
        abv.layer.addSublayer(border4)
        abv.layer.masksToBounds = true
        
        let border5 = CALayer()
        border5.borderWidth = width
        border5.borderColor = UIColor.darkGrayColor().CGColor
        border5.frame = CGRect(x: 0, y: ibu.frame.size.height - 1, width:  ibu.frame.size.width, height: 0.5)
        ibu.layer.addSublayer(border5)
        ibu.layer.masksToBounds = true
        
        let border6 = CALayer()
        border6.borderWidth = width
        border6.borderColor = UIColor.darkGrayColor().CGColor
        border6.frame = CGRect(x: 0, y: profile.frame.size.height - 1, width:  profile.frame.size.width, height: 0.5)
        profile.layer.addSublayer(border6)
        profile.layer.masksToBounds = true
        
        let border7 = CALayer()
        border7.borderWidth = width
        border7.borderColor = UIColor.darkGrayColor().CGColor
        border7.frame = CGRect(x: 0, y: note.frame.size.height - 35, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border7)
        let border8 = CALayer()
        border8.borderWidth = width
        border8.borderColor = UIColor.darkGrayColor().CGColor
        border8.frame = CGRect(x: 0, y: note.frame.size.height - 19, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border8)
        let border9 = CALayer()
        border9.borderWidth = width
        border9.borderColor = UIColor.darkGrayColor().CGColor
        border9.frame = CGRect(x: 0, y: note.frame.size.height - 3, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border9)
        let border10 = CALayer()
        border10.borderWidth = width
        border10.borderColor = UIColor.darkGrayColor().CGColor
        border10.frame = CGRect(x: 0, y: note.frame.size.height + 13, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border10)
        note.layer.masksToBounds = true
        let border11 = CALayer()
        border11.borderWidth = width
        border11.borderColor = UIColor.darkGrayColor().CGColor
        border11.frame = CGRect(x: 0, y: note.frame.size.height + 30, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border11)
        note.layer.masksToBounds = true
        let border12 = CALayer()
        border12.borderWidth = width
        border12.borderColor = UIColor.darkGrayColor().CGColor
        border12.frame = CGRect(x: 0, y: note.frame.size.height + 47, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border12)
        note.layer.masksToBounds = true
        let border13 = CALayer()
        border13.borderWidth = width
        border13.borderColor = UIColor.darkGrayColor().CGColor
        border13.frame = CGRect(x: 0, y: note.frame.size.height + 64, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border13)
        note.layer.masksToBounds = true
        let border14 = CALayer()
        border14.borderWidth = width
        border14.borderColor = UIColor.darkGrayColor().CGColor
        border14.frame = CGRect(x: 0, y: note.frame.size.height + 81, width:  note.frame.size.width, height: 0.5)
        note.layer.addSublayer(border14)
        note.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
