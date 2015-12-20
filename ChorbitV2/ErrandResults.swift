//
//  ErrandResults.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

class ErrandResults {
    
    var locationSearchResults: NearbySearch?
    var errandTermId: Int = 0
    var errandText: String = ""
    var usedPlaceIds: [String] = [""]
    
    init () {
        
    }
    
    init (searchResults: NearbySearch, errandTermId: Int, usedPlaceIds: [String], errandText: String)
    {
        self.locationSearchResults = searchResults;
        self.errandTermId = errandTermId;
        self.usedPlaceIds = usedPlaceIds;
        self.errandText = errandText;
    }
}