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
    var directionsGrouped: [[DirectionStep]] = []
    
    @IBOutlet weak var directionsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //directionsTable.rowHeight = UITableViewAutomaticDimension
        directionsTable.separatorInset = UIEdgeInsetsZero
        directionsTable.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
        directionsTable.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        directionsTable.reloadData()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return directionsGrouped.count
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directionsGrouped[section].count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DirectionCell", forIndexPath: indexPath)
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping

        let item = directionsGrouped[indexPath.section][indexPath.row + 1]
        
        cell.detailTextLabel?.text = item.distance
        cell.textLabel?.text = item.directionText
         var image : UIImage?
        
        if item.directionText.lowercaseString.rangeOfString("turn right") != nil {
          
           image = UIImage(named: "Up Right-32")!
           
        }
        else if item.directionText.lowercaseString.rangeOfString("continue") != nil{
            image = UIImage(named: "Up-32")
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section > 0){
            //space before the to errandtext group title is to add padding. it's a total hack but if you can do it better be my guest..... NJK
        return "     " + directionsGrouped[section][0].errandGroupNumber
        }
        else{
            return ""
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(hexString: "FF6666") //make the background color light blue
        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 13)!
        //header.alpha = 0.5 //make the header transparent
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // remove bottom extra 20px space.
        return CGFloat.min
    }
}