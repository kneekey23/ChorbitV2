//
//  GoogleMapMarker.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 1/10/16.
//  Copyright © 2016 shortkey. All rights reserved.
//


import Foundation
import GoogleMaps

class GoogleMapMarker : GMSMarker {
    
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    var isErrand: Bool = true
    
    override init () {
        
    }
    
    init (coordinate: CLLocationCoordinate2D, title: String, snippet: String, placeId: String, errandText: String, errandOrder: Int?, isErrand: Bool) {
        super.init()
        self.position = coordinate
        self.title = title
        self.snippet = snippet
        self.placeId = placeId
        self.errandText = errandText
        self.errandOrder = errandOrder
        self.isErrand = isErrand
    }
    
}

