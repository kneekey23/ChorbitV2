//
//  GoogleMapsGeocoderResults.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

public class GoogleMapsGeocoderResult
{
    var results: [Result] = [Result()]
    var status: String = ""
    
    init (results: [Result], status: String) {
        self.results = results
        self.status = status
    }
    
    public class AddressComponent
    {
        var long_name: String = ""
        var short_name: String = ""
        var types: [String] = [""]
        
        init (long_name: String, short_name: String, types: [String]) {
            self.long_name = long_name
            self.short_name = short_name
            self.types = types
        }
    }
    
    public class Northeast
    {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    public class Southwest
    {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    public class Bounds
    {
        var northeast: Northeast = Northeast()
        var southwest: Southwest = Southwest()
        
        init (northeast: Northeast, southwest: Southwest) {
            self.northeast = northeast
            self.southwest = southwest
        }
    }
    
    public class Location
    {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    public class Northeast2
    {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    public class Southwest2
    {
        var lat: Double = 0.0
        var lng: Double = 0.0
    }
    
    public class Viewport
    {
        var northeast: Northeast2 = Northeast2()
        var southwest: Southwest2 = Southwest2()
        
        init (northeast: Northeast2, southwest: Southwest2) {
            self.northeast = northeast
            self.southwest = southwest
        }
    }
    
    public class Geometry
    {
        var bounds: Bounds = Bounds()
        var location: Location = Location()
        var location_type: String = ""
        var viewport: Viewport = Viewport()
        
        init (bounds: Bounds, location: Location, location_type: String, viewport: Viewport) {
            self.bounds = bounds
            self.location = location
            self.location_type = location_type
            self.viewport = viewport
        }
    }
    
    public class Result
    {
        var address_components: [AddressComponent] = [AddressComponent()]
        var formatted_address: String = ""
        var geometry: Geometry = Geometry()
        var partial_match: Bool = false
        var place_id: String = ""
        var types: [String] = [""]
        
        init (address_components: [AddressComponent], formatted_address: String, geometry: Geometry, partial_match: Bool, place_id: String, types: [String]) {
            self.address_components = address_components
            self.formatted_address = formatted_address
            self.geometry = geometry
            self.partial_match = partial_match
            self.place_id = place_id
            self.types = types
        }
    }
    
    
    
    
    
    
    
    
}