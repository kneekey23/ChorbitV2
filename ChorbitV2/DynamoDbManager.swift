//
//  DynamoDbManager.swift
//  ChorbitV2
//
//  Created by Nicki on 12/7/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import AWSDynamoDB


class DDBTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var routeName:String?
    var place1:String?
    var place2:String?
    var place3:String?
    var place1Image:String?
    var place1Description: String?
    var place2Image: String?
    var place2Description: String?
    var place3Image: String?
    var place3Description: String?
    var routeDescription: String?
    
    
    class func dynamoDBTableName() -> String! {
        return ThemedRoutesTable
    }
    
    class func hashKeyAttribute() -> String! {
        return "routeName"
    }
    
    
    //MARK: NSObjectProtocol hack
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    
    override func `self`() -> Self {
        return self
    }
}