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
    
    @IBOutlet weak var place3Description: UITextView!
    @IBOutlet weak var place2Description: UITextView!
    @IBOutlet weak var place1Description: UITextView!
    @IBOutlet weak var place1Image: UIImageView!
    @IBOutlet weak var place2Image: UIImageView!
    @IBOutlet weak var place3Image: UIImageView!
    @IBOutlet weak var routeDescription: UITextView!
    
    var tableRow:DDBTableRow?
    var potentialRoute: [String] = []
    
    func imageForImageURLString(imageURLString: String, completion: (image: UIImage?, success: Bool) -> Void) {
        
        guard let url = NSURL(string: imageURLString),
            let data = NSData(contentsOfURL: url),
            let image = UIImage(data: data)
            else {
                completion(image: nil, success: false);
                return
        }
        
        completion(image: image, success: true)
    }
    
    func getTableRow() {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        dynamoDBObjectMapper.load(DDBTableRow.self, hashKey: tableRow?.cityId, rangeKey: tableRow?.routeName) .continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error == nil) {
                if (task.result != nil) {
                    let tableRow = task.result as! DDBTableRow
                    self.routeDescription.text = tableRow.routeDescription

                    let url1 = NSURL(string: tableRow.place1Image!)
                    let url2 = NSURL(string: tableRow.place2Image!)
                    let url3 = NSURL(string: tableRow.place3Image!)
                    self.downloadImage(url1!, imageView: self.place1Image)
                    self.downloadImage(url2!, imageView: self.place2Image)
                    self.downloadImage(url3!, imageView: self.place3Image)
                    self.place1Description.text = tableRow.place1Description
                    self.place2Description.text = tableRow.place2Description
                    self.place3Description.text = tableRow.place3Description
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
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, imageView: UIImageView){

        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func launchThemedRoute(sender: AnyObject) {
        
        let controller = tabBarController as! MainViewController
       
        if( controller.errandSelection.count > 1){
            
            switch(controller.errandSelection.count){
                
            case 2: controller.errandSelection.removeLast()
                break
            case 3: controller.errandSelection.removeRange(1...2)
                break
            case 4: controller.errandSelection.removeRange(1...3)
                break
            case 5: controller.errandSelection.removeRange(1...4)
                break
            case 6: controller.errandSelection.removeRange(1...5)
                break
            case 7: controller.errandSelection.removeRange(1...6)
                break
            default: controller.errandSelection.removeLast()
                break
            }
           
        }
        
        for errand in potentialRoute{
            let newErrand: Errand = Errand(errandString: errand, isAddress: false, isStartingLocation: false, isEndingLocation: false)
             controller.errandSelection.append(newErrand)
        }
      
        tabBarController?.selectedIndex = 0
        let firstNavController: UINavigationController = tabBarController?.selectedViewController as! UINavigationController;
        firstNavController.popToRootViewControllerAnimated(true)
        

    }
}