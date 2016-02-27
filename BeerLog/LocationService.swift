//
//  LocationService.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/04.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate {
    // 位置情報使用拒否Notification
    public let LSAuthDeniedNotification = "LSAuthDeniedNotification"
    // 位置情報使用制限Notification
    public let LSAuthRestrictedNotification = "LSAuthRestrictedNotification"
    // 位置情報使用可能Notification
    public let LSAuthorizedNotification = "LSAuthorizedNotification"
    // 位置情報取得完了Notification
    public let LSDidUpdateLocationNotification = "LSDidUpdateLocationNotification"
    // 位置情報取得失敗Notification
    public let LSDidFailLocationNotification = "LSDidFailLocationNotification"
    
    private let cllm = CLLocationManager()
    private let nsnc = NSNotificationCenter.defaultCenter()
    
    // 位置情報がONになっていないダイアログ
    public var locationServiceDisabledAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "BeerLog does not have access to Location service",
                message: "You can enable access in Settings -> Privacy -> Location -> Location Services",
                preferredStyle: .Alert)
            
            alert.addAction(
                UIAlertAction(title: "Close", style: .Cancel, handler: nil)
            )
            
            return alert
        }
    }
    
    // 位置情報が制限されているダイアログ
    public var locationServiceRestrictedAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "BeerLog does not have access to Location service",
                message: "You can enable access in Settings -> Privacy -> Location -> Location Services",
                preferredStyle: .Alert)
            
            alert.addAction(
                UIAlertAction(title: "Close", style: .Cancel, handler: nil)
            )
            
            return alert
        }
    }
    
    // 位置情報取得に失敗したダイアログ
    public var locationServiceDidFailAlert: UIAlertController {
        get {
            let alertView = UIAlertController(title: nil, message: "BeerLog does not have access to Location service", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            return alertView
        }
    }
    
    // イニシャライザ
    public override init(){
        super.init()
        cllm.delegate = self
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // 位置情報の使用許可状態が変化した時に実行される
    public func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
            switch status {
            case .NotDetermined:
                // まだ意思表示をしていない
                cllm.requestWhenInUseAuthorization()
            case .Restricted:
                // 制限している
                nsnc.postNotificationName(LSAuthRestrictedNotification, object: nil)
            case .Denied:
                // 禁止している
                nsnc.postNotificationName(LSAuthDeniedNotification, object: nil)
            case .AuthorizedWhenInUse:
                // 利用可能
                break;
            default:
                // それ以外（通常ありえない）
                break;
            }
    }
    
    // 位置情報を取得した時に実行される
    public func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
            
            // 位置情報の取得を停止
            cllm.stopUpdatingLocation()
            // locationsは配列なので最後の1つを使用する
            if let location = locations.last {
                // 位置情報を乗せてNotificationを送信する
                nsnc.postNotificationName(LSDidUpdateLocationNotification,
                    object: self,
                    userInfo: ["location": location])
            }
    }
    
    // 位置情報の取得に失敗した時に実行される
    public func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
            
            // 失敗Notificationを送信する
            nsnc.postNotificationName(LSDidFailLocationNotification, object: nil)
    }
    
    // MARK: - アプリケーションロジック
    
    // 位置情報の取得を開始する
    public func startUpdatingLocation(){
        cllm.startUpdatingLocation()
    }
}

