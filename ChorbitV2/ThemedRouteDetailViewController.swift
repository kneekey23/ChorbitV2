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
                    //self.place1Image.imageFromUrl(tableRow.place1Image!)
                    //self.place2Image.imageFromUrl(tableRow.place2Image!)
                    //self.place3Image.imageFromUrl(tableRow.place3Image!)
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
        var errandArray = (parentViewController?.parentViewController as! MainViewController).errandSelection
        if(errandArray.count > 0){
            errandArray.removeAll()
        }
        
        for errand in potentialRoute{
            errandArray.append(errand)
        }
        //TODO: fix this function so that it doesn't break. NJK
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKindOfClass(SearchViewController) {
                self.navigationController?.popToViewController(controller as UIViewController, animated: true)
                break
            }
        }
    }
}