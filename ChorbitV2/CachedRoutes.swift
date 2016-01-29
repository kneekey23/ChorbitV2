//
//  CachedRoutes.swift
//  Chorbit
//
//  Created by Melissa Hargis on 1/28/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation

class CachedRoutes {
    
    var driving: [GoogleMapMarker] = []
    var walking: [GoogleMapMarker] = []
    var cycling: [GoogleMapMarker] = []
    
    init () {
        
    }
    
    init (driving: [GoogleMapMarker], walking: [GoogleMapMarker], cycling: [GoogleMapMarker]) {
        self.driving = driving
        self.walking = walking
        self.cycling = cycling
    }
    
}
