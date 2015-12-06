//
//  FeaturedRouteController.swift
//  ChorbitV2
//
//  Created by Nicki on 11/21/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit

class FeaturedRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var featuredRouteTable: UITableView!
    var featuredRouteList: [String] = ["Tourist Route", "Lazy Sunday Route"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featuredRouteTable.separatorInset = UIEdgeInsetsZero
        //grab featuredRouteList from db here NJK
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuredRouteList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("featuredRouteCell", forIndexPath: indexPath)
        
        // Get the corresponding candy from our candies array
        let featuredRoute = featuredRouteList[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = featuredRoute
        //TODO: set subtitle to list out places NJK
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    
}