//
//  MapboxMapMarker.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 1/17/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation
import Mapbox

class MapboxMapMarker : MGLPointAnnotation {
    
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    
    override init () {
        
    }
    
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String, placeId: String, errandText: String, errandOrder: Int?) {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.placeId = placeId
        self.errandText = errandText
        self.errandOrder = errandOrder
    }
    
}
