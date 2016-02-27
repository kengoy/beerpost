//
//  BeerBarListItemTableViewCell.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2015/12/28.
//  Copyright © 2015年 dr.sunoo. All rights reserved.
//

import UIKit
import CoreLocation

class BeerBarListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView! {
        didSet {
            photo.layer.cornerRadius = 5.0
            photo.clipsToBounds = true
        }
    }
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var tipsUserPhoto: UIImageView! {
        didSet {
            tipsUserPhoto.layer.cornerRadius = 22.0
            tipsUserPhoto.clipsToBounds = true
        }
    }
    @IBOutlet weak var tipsText: UILabel!

    var cl = CLLocation()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
