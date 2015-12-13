//
//  Copyright.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

class Copyright {
    
    var text: String = ""
    var imageUrl: String = ""
    var imageAltText: String = ""
    
    init () {
        
    }
    
    init (text: String, imageUrl: String, imageAltText: String) {
        self.text = text
        self.imageUrl = imageUrl
        self.imageAltText = imageAltText
    }
}