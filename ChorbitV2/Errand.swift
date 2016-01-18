//
//  Errand.swift
//  ChorbitV2
//
//  Created by Nicki on 1/17/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation


class Errand{
    
    var errandString: String = ""
    var isAddress: Bool = false
    var isStartingLocation: Bool = false
    var isEndingLocation: Bool = false
    
    init () {
        
    }
    
    init (errandString: String, isAddress: Bool, isStartingLocation: Bool, isEndingLocation: Bool) {
        self.errandString = errandString
        self.isAddress = isAddress
        self.isEndingLocation = isEndingLocation
        self.isStartingLocation = isStartingLocation
    }
}