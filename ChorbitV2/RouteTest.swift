//
//  RouteTest.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

public class RouteTest
{
    var totalMiles: Double = 0.0
    var sequence: [Int] = [0]
    
    init () {
        
    }
    
    init (totalMiles: Double, sequence: [Int]) {
        self.totalMiles = totalMiles
        self.sequence = sequence
    }
}