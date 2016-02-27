//
//  BeerLogInfoViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/02/15.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit

class BeerLogInfoViewController: UIViewController {

    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appVersion: UILabel!
    @IBOutlet weak var licensesText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainBundle = NSBundle.mainBundle()
        appName.text = mainBundle.infoDictionary!["CFBundleName"] as? String
        appVersion.text = "Ver " + String(mainBundle.infoDictionary!["CFBundleShortVersionString"] as! String)
        
        if let path = mainBundle.pathForResource("Licenses", ofType: "plist") {
            if let items = NSDictionary(contentsOfFile: path) {
                var text = String()
                for item in items {
                    if let key = item.key as? String {
                        text += key + "\n\n"
                        text += item.value as! String + "\n\n\n"
                    }
                }
                licensesText.text = text
            }
        }
    }
}
