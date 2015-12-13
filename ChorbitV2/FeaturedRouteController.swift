//
//  FeaturedRouteController.swift
//  ChorbitV2
//
//  Created by Nicki on 11/21/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSDynamoDB



class FeaturedRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var featuredRouteTable: UITableView!
    var featuredRouteList:Array<DDBTableRow>?
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    var  doneLoading = false
    
    var needsToRefresh = true
    //var featuredRouteList: [String] = ["Tourist Route", "Lazy Sunday Route"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featuredRouteTable.separatorInset = UIEdgeInsetsZero
        featuredRouteList = []
        lock = NSLock()

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needsToRefresh {
            self.refreshList(true)
            self.needsToRefresh = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshList(startFromBeginning: Bool)  {
        if (self.lock?.tryLock() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20;
            dynamoDBObjectMapper.scan(DDBTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.featuredRouteList?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [DDBTableRow] {
                        self.featuredRouteList?.append(item)
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.featuredRouteTable.reloadData()
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (featuredRouteList?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("featuredRouteCell", forIndexPath: indexPath)
        
        // Configure the cell...
        if let myTableRows = self.featuredRouteList {
            let item = myTableRows[indexPath.row]
            cell.textLabel?.text = item.routeName!
            
            if let myDetailTextLabel = cell.detailTextLabel {
                myDetailTextLabel.text = "\(item.place1!), \(item.place2!), \(item.place3!                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              )"
            }
            
            if indexPath.row == myTableRows.count - 1 && !self.doneLoading {
                self.refreshList(false)
            }
        }
    
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("ThemedRouteDetailViewController", sender: featuredRouteTable.cellForRowAtIndexPath(indexPath))
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "ThemedRouteDetailViewController" {
            let detailViewController = segue.destinationViewController as! ThemedRouteDetailViewController
            if sender != nil {
                if (sender!.isKindOfClass(UITableViewCell)) {
                    let cell = sender as! UITableViewCell
                    
                    
                    let indexPath = self.featuredRouteTable.indexPathForCell(cell)
                    let tableRow = self.featuredRouteList?[indexPath!.row]
                    detailViewController.tableRow = tableRow
                    
                }
                
            }
        }
        
        
        
    }
    

    
}