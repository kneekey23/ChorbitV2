//
//  RouteServiceResponse.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 1/9/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation

class RouteServiceResponse {
    
    /**
     * Lat: 33.38058277
     * Long: -117.20407051
     */
    let results: [RouteResults]
    
    init (_ json: [String: AnyObject]) {
        
        if let results = json["results"] as? [[String: AnyObject]] {
            var result = [RouteResults]()
            for obj in results {
                result.append(RouteResults(obj))
            }
            self.results = result
        } else {
            self.results = [RouteResults]()
        }
    }
}

class RouteResults {
    
    /** lat: 33.38058277 */
    let lat: Double
    
    /** long: -117.20407051 */
    let long: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let long = json["long"] as? Double { self.long = long }
        else { self.long = 0 }
    }
}

