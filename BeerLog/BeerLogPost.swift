//
//  Post.swift
//  BeerLog
//
//  Created by Kengo Yoshii on 2016/01/15.
//  Copyright © 2016年 dr.sunoo. All rights reserved.
//

import UIKit
import RealmSwift

class BeerLogPost: Object {
    
//    dynamic var createdDate: String = ""
    dynamic var id: String!
    dynamic var userId: String!
    dynamic var createdDate : NSDate = NSDate()
    dynamic var createdPlace: String!
    dynamic var postImage: NSData!
    dynamic var postBeerName: String!
    dynamic var postBreweryName: String!
    dynamic var postBreweryCountry: String!
    var postABV = RealmOptional<Float>()
    var postIBU = RealmOptional<Int>()
    dynamic var postProfile: String!
    var postScore = RealmOptional<Float>()
    dynamic var postNote: String!
    dynamic var numberOfLikes: Int = 0
    
    convenience init(userId: String!, createdPlace: String!, postImage: NSData!,
        postBeerName: String!, postBreweryName: String!, postBreweryCountry: String!, postABV: Float!,
        postIBU: Int!, postProfile: String!, postScore: Float!, postNote: String!
        )
    {
        self.init()

        id = ""
        self.userId = userId
        self.createdPlace = createdPlace
        self.postImage = postImage
        self.postBeerName = postBeerName
        self.postBreweryName = postBreweryName
        self.postBreweryCountry = postBreweryCountry
        self.postABV.value = postABV
        self.postIBU.value = postIBU
        self.postProfile = postProfile
        self.postScore.value = postScore
        self.postNote = postNote
    }
    
}