//
//  Coordinates.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

class Coordinates {
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var title: String = ""
    var subtitle: String = ""
    var errandTermId: Int = 0
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    
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
    
}
