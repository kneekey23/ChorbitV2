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
     * long: -117.0748985
     * title: "Trader Joe's"
     * errandText: "trader joe's"
     * errandTermId: 2
     * subtitle: "1885 South Centre City Parkway, Escondido"
     * placeId: "ChIJV0p-BYbz24AR7XcIr1VeSYk"
     * lat: 33.09998350000001
     */
    let results: [Coordinates]
    
    init (_ json: [String: AnyObject]) {
        
        if let results = json["results"] as? [[String: AnyObject]] {
            var result = [Coordinates]()
            for obj in results {
                result.append(Coordinates(obj))
            }
            self.results = result
        } else {
            self.results = [Coordinates]()
        }
    }
}

class RouteResults {
    
    /** long: -117.0748985 */
    let long: Double
    
    /** title: "Trader Joe's" */
    let title: String
    
    /** errandText: "trader joe's" */
    let errandText: String
    
    /** errandTermId: 2 */
    let errandTermId: Int
    
    /** subtitle: "1885 South Centre City Parkway, Escondido" */
    let subtitle: String
    
    /** placeId: "ChIJV0p-BYbz24AR7XcIr1VeSYk" */
    let placeId: String
    
    /** lat: 33.09998350000001 */
    let lat: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let long = json["long"] as? Double { self.long = long }
        else { self.long = 0 }
        
        if let title = json["title"] as? String { self.title = title }
        else { self.title = "" }
        
        if let errandText = json["errandText"] as? String { self.errandText = errandText }
        else { self.errandText = "" }
        
        if let errandTermId = json["errandTermId"] as? Int { self.errandTermId = errandTermId }
        else { self.errandTermId = 0 }
        
        if let subtitle = json["subtitle"] as? String { self.subtitle = subtitle }
        else { self.subtitle = "" }
        
        if let placeId = json["placeId"] as? String { self.placeId = placeId }
        else { self.placeId = "" }
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
    }
}


