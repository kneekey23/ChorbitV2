//
//  CityListViewController.swift
//  ChorbitV2
//
//  Created by Nicki on 1/23/16.
//  Copyright © 2016 shortkey. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSDynamoDB

class CityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var listOfCities: [String] = []
    var  doneLoading = false
    var needsToRefresh = true
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    var cityList:Array<CityTableRow>?
    
    @IBOutlet weak var cityTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        cityTable.separatorInset = UIEdgeInsetsZero
        cityList = []
        cityTable.tableFooterView = UIView()
        lock = NSLock()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.needsToRefresh{
            self.refreshList(true)
            self.needsToRefresh = false
        }
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
            
            dynamoDBObjectMapper.scan(CityTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.cityList?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [CityTableRow] {
                        self.cityList?.append(item)
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.cityTable.reloadData()
                self.dismissViewControllerAnimated(false, completion: nil)
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (cityList?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cityCell", forIndexPath: indexPath)
        
        // Configure the cell...
        if let myTableRows = self.cityList {
            let item = myTableRows[indexPath.row]
            cell.textLabel?.text = item.cityName!
            
            
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
        
        self.performSegueWithIdentifier("cityListIdentifier", sender: cityTable.cellForRowAtIndexPath(indexPath))
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "cityListIdentifier" {
            let featuredRouteController = segue.destinationViewController as! FeaturedRouteViewController
            if sender != nil {
                if (sender!.isKindOfClass(UITableViewCell)) {
                    let cell = sender as! UITableViewCell
                    
                    
                    let indexPath = self.cityTable.indexPathForCell(cell)
                    let tableRow = self.cityList?[indexPath!.row]
                    featuredRouteController.cityId = tableRow!.cityId
                    
                }
                
            }
        }
        
        
        
    }
    
}
