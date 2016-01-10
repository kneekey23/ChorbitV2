//
//  Coordinates.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import ObjectMapper

class Coordinates: Mappable {
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var title: String = ""
    var subtitle: String = ""
    var errandTermId: Int = 0
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    
    init () {
        
    }
    
    init (lat: Double, long: Double, title: String, subtitle: String, errandTermId: Int, placeId: String, errandText: String, errandOrder: Int?) {
        self.lat = lat
        self.long = long
        self.title = title
        self.subtitle = subtitle
        self.errandTermId = errandTermId
        self.placeId = placeId
        self.errandText = errandText
        self.errandOrder = errandOrder
    }
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let long = json["long"] as? Double { self.long = long }
        else { self.long = 0 }
    }
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        lat      <- map["lat"]
        long     <- map["long"]
        title <- map["title"]
        subtitle <- map["subtitle"]
        errandTermId <- map["errandTermId"]
        placeId <- map["placeId"]
        errandText <- map["errandText"]
        errandOrder <- map["errandOrder"]
    }
}
