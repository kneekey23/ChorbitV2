//
//  RouteServiceRequest.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 1/9/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation

class RouteServiceRequest {
    
    var origin: Coordinates
    var errands: [[Coordinates]]
    var destination: Coordinates
    
    init (origin: Coordinates, errands: [[Coordinates]], destination: Coordinates)
    {
        self.origin = origin
        self.errands = errands
        self.destination = destination
    }
}