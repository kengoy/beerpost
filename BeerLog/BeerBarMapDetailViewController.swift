//
//  BeerBarMapDetailViewController.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/10.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import MapKit

class BeerBarMapDetailViewController: UIViewController {

    @IBOutlet weak var showCurrentLocationButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!

    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    var shop = Shop()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let lat = shop.lat {
            if let lon = shop.lon {
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 500, 500)
                map.setRegion(mkcr, animated: false)

                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                pin.title = shop.name
                map.addAnnotation(pin)
            }
        }
        
        self.navigationItem.title = shop.name
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "E78534")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    // 現在地を表示ボタンを非アクティブにする
                    self.showCurrentLocationButton.enabled = false
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
                    // 現在地を表示ボタンを非アクティブにする
                    self.showCurrentLocationButton.enabled = false
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
                    // 現在地を表示ボタンを非アクティブにする
                    self.showCurrentLocationButton.enabled = false
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
                            // userInfoがキーlocationを持っている
                            
                            if let lat = self.shop.lat {
                                if let lon = self.shop.lon {
                                    // 店舗が位置情報を持っている→地図の表示範囲を設定する
                                    let center = CLLocationCoordinate2D(
                                        latitude: (lat + clloc.coordinate.latitude) / 2,
                                        longitude: (lon + clloc.coordinate.longitude) / 2
                                    )
                                    let diff = (
                                        lat: abs(clloc.coordinate.latitude - lat),
                                        lon: abs(clloc.coordinate.longitude - lon))
                                    
                                    // 表示範囲を設定する
                                    let mkcs = MKCoordinateSpanMake(diff.lat * 1.4, diff.lon * 1.4)
                                    let mkcr = MKCoordinateRegionMake(center, mkcs)
                                    self.map.setRegion(mkcr, animated: true)
                                    
                                    // 現在地を表示する
                                    self.map.showsUserLocation = true
                                }
                            }
                        }
                    }
                    // [現在地を表示]ボタンをアクティブにする
                    self.showCurrentLocationButton.enabled = true
            })
        )
        // 位置情報が利用可能になった場合
        observers.append( 
            nc.addObserverForName(ls.LSAuthorizedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    
                    // [現在地を表示]ボタンをアクティブにする
                    self.showCurrentLocationButton.enabled = true
            })
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        // 通知の待受を解除する
        for observer in observers { 
            nc.removeObserver(observer)
        }
        observers = [] 
    }
    
    @IBAction func showCurrentLocationButtonTapped(sender: UIBarButtonItem) {
        ls.startUpdatingLocation()
    }

}
