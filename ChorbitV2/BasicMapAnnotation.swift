//
//  BasicMapAnnotation.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import GoogleMaps

class BasicMapAnnotation : GMSMarker {
    
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    
    override init () {
        
    }
    
    init (coordinate: CLLocationCoordinate2D, title: String, snippet: String, placeId: String, errandText: String, errandOrder: Int?) {
        super.init()
        self.position = coordinate
        self.title = title
        self.snippet = snippet
        self.placeId = placeId
        self.errandText = errandText
        self.errandOrder = errandOrder
    }
    
}
