//
//  ThemedRouteDetailViewController.swift
//  ChorbitV2
//
//  Created by Nicki on 12/7/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB


class ThemedRouteDetailViewController: UIViewController {
    
    @IBOutlet weak var place1Image: UIImageView!
    @IBOutlet weak var place2Image: UIImageView!
    @IBOutlet weak var place3Image: UIImageView!
    @IBOutlet weak var routeDescription: UITextView!
    
    var tableRow:DDBTableRow?
    var potentialRoute: [String] = []
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.load(DDBTableRow.self, hashKey: tableRow?.routeName, rangeKey: nil) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! DDBTableRow
                    self.routeDescription.text = tableRow.routeDescription
                    //TODO: display images properly NJK
                    self.place1Image.downloadedFrom(link: tableRow.place1Image!, contentMode: UIViewContentMode.ScaleAspectFit)
                    self.place2Image.downloadedFrom(link: tableRow.place2Image!, contentMode: UIViewContentMode.ScaleAspectFit)
                    self.place3Image.downloadedFrom(link: tableRow.place3Image!, contentMode: UIViewContentMode.ScaleAspectFit)
                    self.potentialRoute.append(tableRow.place1!)
                    self.potentialRoute.append(tableRow.place2!)
                    self.potentialRoute.append(tableRow.place3!)
                
                }
            } else {
                print("Error: \(task.error)")
                let alertController = UIAlertController(title: "Failed to get item from table.", message: task.error.description, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in
                })
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            return nil
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        self.getTableRow()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
    
    @IBAction func launchThemedRoute(sender: AnyObject) {
        let controller = tabBarController as! MainViewController
       
        if( controller.errandSelection.count > 1){
            
             controller.errandSelection.removeRange(1...4)
        }
        
        for errand in potentialRoute{
             controller.errandSelection.append(errand)
        }
      
        tabBarController?.selectedIndex = 0

    }
}