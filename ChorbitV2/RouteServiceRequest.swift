//
//  RouteServiceRequest.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 1/9/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation
import ObjectMapper

class RouteServiceRequest: Mappable {
    
    var origin: Coordinates = Coordinates()
    var errands: [[Coordinates]] = [[Coordinates()]]
    var destination: Coordinates = Coordinates()
    
    
    init (origin: Coordinates, errands: [[Coordinates]], destination: Coordinates)
    {
        self.origin = origin
        self.errands = errands
        self.destination = destination
    }
    
    required init?(_ map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        origin      <- map["origin"]
        errands     <- map["errands"]
        destination <- map["destination"]
    }
}