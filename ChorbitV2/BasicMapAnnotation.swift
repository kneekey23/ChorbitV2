//
//  BasicMapAnnotation.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class BasicMapAnnotation : MKAnnotation {
    
//    C#:
//    public override string Title { get { return title; } }
//    public override string Subtitle { get { return subtitle; } }
    
    
    var coords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var title: String = ""
    var subtitle: String = ""
//    override var Title: String = ""
//    override var Subtitle: String = ""
    var placeId: String = ""
    var errandText: String = ""
    var errandOrder: Int? = 0
    
    override func coordinate() -> CLLocationCoordinate2D {
        return self.coords;
    }
    
    override func setCoordinate(value: CLLocationCoordinate2D) {
        coords = value;
    }
    
    init () {
        
    }
    
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String, placeId: String, errandText: String, errandOrder: Int?) {
        self.coords = coordinate
        self.title = title
        self.subtitle = subtitle
        self.placeId = placeId
        self.errandText = errandText
        self.errandOrder = errandOrder
    }
    
}
