//
//  NSDateExtension.swift
//
//  Created by Kengo Yoshii on 2016/01/15.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import Foundation

extension NSDate
{
    static func shortStringFromDate(date: NSDate) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(date)
    }
}
