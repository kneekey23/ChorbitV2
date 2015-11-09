//
//  ErrandDistance.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

class ErrandDistance {
    
    var locations: [Coordinates] = [Coordinates()]
    var distances: [[Double]] = [[0.0]]
    var startIndex: Int = 0
    
    init () {
        
    }
    
    init (locations: [Coordinates], distances: [[Double]], startIndex: Int) {
        self.locations = locations
        self.distances = distances
        self.startIndex = startIndex
    }
}