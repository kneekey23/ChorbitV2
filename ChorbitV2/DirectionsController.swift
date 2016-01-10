//
//  DirectionsController.swift
//  ChorbitV2
//
//  Created by Nicki on 12/28/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit

class DirectionsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var directions: [DirectionStep] = []
    
    @IBOutlet weak var directionsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //directionsTable.rowHeight = UITableViewAutomaticDimension
        directionsTable.separatorInset = UIEdgeInsetsZero
        directionsTable.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        directionsTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell", forIndexPath: indexPath)
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping

        let item = directions[indexPath.row]
        
        cell.detailTextLabel?.text = item.distance
        cell.textLabel?.text = item.directionText
         var image : UIImage?
        
        if item.directionText.lowercaseString.rangeOfString("turn right") != nil {
          
           image = UIImage(named: "Up Right-32")!
           
        }
        else if item.directionText.lowercaseString.rangeOfString("turn left") != nil{
            image = UIImage(named: "Up Left-32")
            
        }
        else if item.directionText.lowercaseString.rangeOfString("U-turn") != nil{
            image = UIImage(named: "Undo-32")
        }
        
        if image != nil{
            cell.imageView!.image = image
        }
        
        
        return cell
    }
}