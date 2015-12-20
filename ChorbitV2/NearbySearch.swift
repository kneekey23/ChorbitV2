//
//  File.swift
//  ChorbitV2
//
//  Created by Nicki on 12/13/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

import Foundation

class NearbySearch {
    
    var html_attributions: [AnyObject]?
    
    var results: [Results]
    
    var status: String
    
    init (_ json: [String: AnyObject]) {
        
        if let results = json["results"] as? [[String: AnyObject]] {
            var result = [Results]()
            for obj in results {
                result.append(Results(obj))
            }
            self.results = result
        } else {
            self.results = [Results]()
        }
        
        if let status = json["status"] as? String { self.status = status }
        else { self.status = "" }
    
}
}

class Results {
    
    let geometry: Geometry
    
    let icon: String
    
    /** id: "21a0b251c9b8392186142c798263e289fe45b4aa" */
    let id: String
    
    /** name: "Rhythmboat Cruises" */
    let name: String
    
    let photos: [Photos]
    
    /** place_id: "ChIJyWEHuEmuEmsRm9hTkapTCrk" */
    let place_id: String

    let reference: String
    
    let scope: String
    
    let types: [String]
  
    let vicinity: String
    
    init (_ json: [String: AnyObject]) {
        
        if let geometry = json["geometry"] as? [String: AnyObject] { self.geometry = Geometry(geometry) }
        else { self.geometry = Geometry([ : ]) }
        
        if let icon = json["icon"] as? String { self.icon = icon }
        else { self.icon = "" }
        
        if let id = json["id"] as? String { self.id = id }
        else { self.id = "" }
        
        if let name = json["name"] as? String { self.name = name }
        else { self.name = "" }
        
        if let photos = json["photos"] as? [[String: AnyObject]] {
            var result = [Photos]()
            for obj in photos {
                result.append(Photos(obj))
            }
            self.photos = result
        } else {
            self.photos = [Photos]()
        }
        
        if let place_id = json["place_id"] as? String { self.place_id = place_id }
        else { self.place_id = "" }
        
        if let reference = json["reference"] as? String { self.reference = reference }
        else { self.reference = "" }
        
        if let scope = json["scope"] as? String { self.scope = scope }
        else { self.scope = "" }
        
        if let types = json["types"] as? [String] { self.types = types }
        else { self.types = [String]() }
        
        if let vicinity = json["vicinity"] as? String { self.vicinity = vicinity }
        else { self.vicinity = "" }
    }
}

class Photos {
    
    /** height: 480 */
    let height: Int
    
    /** html_attributions: [
     * 	  "<a href=\"https://maps.google.com/maps/contrib/104066891898402903288/photos\">Rhythmboat Cruises</a>",
     * 	  ...
     * 	]
     */
    let html_attributions: [String]
    
    /** photo_reference: "CmRdAAAA7tGN49d3rNcnfA9D7VCEG-Xpe7gX8i3albYVrhzM-85aTssO0YcSmP2HFwnwcXVGGJexAftd1LNcwijIoa_ypvZMOjXugbj1jtcRIAOazjc-UJJ5EhST-94sPAjrJ1l5EhDFSo6uCiGwj9a6qFmKZqgeGhQ7hZln7_-osyn08rNE6qSPcujSSw" */
    let photo_reference: String
    
    /** width: 640 */
    let width: Int
    
    init (_ json: [String: AnyObject]) {
        
        if let height = json["height"] as? Int { self.height = height }
        else { self.height = 0 }
        
        if let html_attributions = json["html_attributions"] as? [String] { self.html_attributions = html_attributions }
        else { self.html_attributions = [String]() }
        
        if let photo_reference = json["photo_reference"] as? String { self.photo_reference = photo_reference }
        else { self.photo_reference = "" }
        
        if let width = json["width"] as? Int { self.width = width }
        else { self.width = 0 }
    }
}

class Geometry {
    
    /** 
     * lat: -33.8687895
     * lng: 151.1942171
     */
    let location: Location
    
    init (_ json: [String: AnyObject]) {
        
        if let location = json["location"] as? [String: AnyObject] { self.location = Location(location) }
        else { self.location = Location([ : ]) }
    }
}

class Location {
    
    /** lat: -33.8687895 */
    let lat: Double
    
    /** lng: 151.1942171 */
    let lng: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let lng = json["lng"] as? Double { self.lng = lng }
        else { self.lng = 0 }
    }
}

