//
//  SearchViewController.swift
//  ChorbitV2
//
//  Created by Nicki on 11/21/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    //any declarations of the class go up here like usual NJK
    //IBActions are actions connected with clicks or touches on the UI. IBOutlets are just variable names for things on the UI so you can refer to it. NJK    
    var myGeoLocatedCoords: CLLocation = CLLocation()
    var isAddressOnly: Bool = false;
    var addressString : String = ""

    @IBOutlet weak var destinationToggle: UISwitch!
    @IBOutlet weak var startingLocationControl: UISegmentedControl!
    @IBOutlet weak var errandTableView: UITableView!
    let locMan: CLLocationManager = CLLocationManager()

    @IBAction func launchButton(sender: AnyObject) {
    }
    
    @IBAction func addErrand(sender: AnyObject) {
        
        let gpaViewController = GooglePlacesAutocomplete(
            apiKey: "AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY",
            placeType: .All,
            isAddressOnly: false
        )
        
        gpaViewController.placeDelegate = self
       
        gpaViewController.locationBias = LocationBias(latitude: myGeoLocatedCoords.coordinate.latitude, longitude: myGeoLocatedCoords.coordinate.longitude, radius: 20)
        gpaViewController.navigationBar.barStyle = UIBarStyle.Default
        gpaViewController.navigationBar.translucent = false
        gpaViewController.navigationBar.barTintColor = UIColor(hexString: "#64D8C4")
        gpaViewController.navigationBar.tintColor = UIColor.whiteColor()
        gpaViewController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16.0)!]
        
        presentViewController(gpaViewController, animated: true, completion: nil)
    }
    
    @IBAction func chooseStartingPoint(sender: AnyObject) {
        let segmentedControl: UISegmentedControl = sender as! UISegmentedControl
        if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "Use New Location"{
            if((parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
            (parentViewController?.parentViewController as! MainViewController).errandSelection.removeFirst()
            }
            isAddressOnly = true
            let gpaViewController = GooglePlacesAutocomplete(
                apiKey: "AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY",
                placeType: .Address,
                isAddressOnly: isAddressOnly
            )
            
            gpaViewController.placeDelegate = self
            gpaViewController.navigationBar.barStyle = UIBarStyle.Default
            gpaViewController.navigationBar.translucent = false
            gpaViewController.navigationBar.barTintColor = UIColor(hexString: "#64D8C4")
            gpaViewController.navigationBar.tintColor = UIColor.whiteColor()
            gpaViewController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16.0)!]
            
            
            presentViewController(gpaViewController, animated: true, completion: nil)
            
        }
        else{
            //delete existing first location if there is one NJK
            if((self.parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
             (self.parentViewController?.parentViewController as! MainViewController).errandSelection.removeFirst()
            }
            //grab current location again NJK
            locMan.startUpdatingLocation()
            
        }
        
    }
    
    @IBAction func toggleEndingLocation(sender: AnyObject) {
        //gets called when you toggle roundtrip switch and adds the ui text field if switched to off. NJK
        if !(sender as! UISwitch).on
        {
            let gpaViewController = GooglePlacesAutocomplete(
                apiKey: "AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY",
                placeType: .Address,
                isAddressOnly: true
            )
            
            gpaViewController.placeDelegate = self
            //swap out lat and long with either current location or selected location
            gpaViewController.navigationBar.barStyle = UIBarStyle.Default
            gpaViewController.navigationBar.translucent = false
            gpaViewController.navigationBar.barTintColor = UIColor(hexString: "#64D8C4")
            gpaViewController.navigationBar.tintColor = UIColor.whiteColor()
            gpaViewController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 16.0)!]
            
            
            presentViewController(gpaViewController, animated: true, completion: nil)
        }

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //reloads TableData when you return to page in case you updated from another page. NJK
        if(self.errandTableView != nil){
            self.errandTableView.reloadData()
        }
        
        locMan.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locMan.delegate = self
        locMan.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locMan.requestWhenInUseAuthorization()
        locMan.startUpdatingLocation()
        //this gets rid of ui issue where image blocks line from showing up completely NJK
        if(self.errandTableView != nil){
             self.errandTableView!.separatorInset = UIEdgeInsetsZero;
        }
       
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //adds the ability to get rid of they keyboard for any text field on return.NJK
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true;
    }
    
    //for a table view to work, you first declare a count of the number of items NJK
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if((self.parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
            return (parentViewController?.parentViewController as! MainViewController).errandSelection.count
        }
        else{
            return 0
        }
      
    }
    //then you declare what you want to display in the cell NJK
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("errandCell", forIndexPath: indexPath)

        let errand = (parentViewController?.parentViewController as! MainViewController).errandSelection[indexPath.row]
        
        // Configure the cell
        cell.textLabel!.text = errand
        
        
        return cell
    }
    //this function gets called if you select one. not sure we need it for this page but leaving it here. NJK
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    //so you can delete errands and locations NJK
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            (parentViewController?.parentViewController as! MainViewController).errandSelection.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation: CLLocation = locations[0] as CLLocation
        let geocoder: CLGeocoder = CLGeocoder()
        //if horizontal accuracy is greater than 0 we have a better chance of grabbing the most accurate location NJK
        if newLocation.horizontalAccuracy >= 0 {
            myGeoLocatedCoords = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            
            geocoder.reverseGeocodeLocation(myGeoLocatedCoords,
                completionHandler: { (array:[CLPlacemark]?, error:NSError?) -> Void in
              
                    if(array!.count > 0){
                        let myPlacemark: CLPlacemark = array![0]
                    
            
                    if myPlacemark.subThoroughfare != nil {
                        addressString = myPlacemark.subThoroughfare! + " "
                    }
                    if myPlacemark.thoroughfare != nil {
                        addressString = addressString + myPlacemark.thoroughfare! + ", "
                    }
                    if myPlacemark.locality != nil {
                        addressString = addressString + myPlacemark.locality! + ", "
                    }
                    if myPlacemark.administrativeArea != nil {
                        addressString = addressString + myPlacemark.administrativeArea!
                    }
                    }

                    if((self.parentViewController?.parentViewController as! MainViewController).errandSelection.count == 0){
                    (self.parentViewController?.parentViewController as! MainViewController).errandSelection.insert(addressString, atIndex: 0)
                        self.errandTableView.reloadData()
                    }
                  
            
            })
              self.locMan.stopUpdatingLocation()
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if error.code == CLError.Denied.rawValue{
            //alert the user they cannot use their current location in the app
            locMan.stopUpdatingLocation()
        }
        else if error.code == CLError.Network.rawValue{
            //alert the user that they don't have network connection to retrieve their location and use the app
        }
        else if error.code == CLError.LocationUnknown.rawValue{
            //alert the user we were unable to retrieve their location.
        }
    }
    
    
}

//extension methods of our controller that get called by the autocomplete class NJK
extension SearchViewController: GooglePlacesAutocompleteDelegate {
    //when you pick something on autocomplete this gets called. NJK
    func placeSelected(place: Place) {
  
        if((parentViewController?.parentViewController as! MainViewController).errandSelection.count <= 10){
            if(!self.isAddressOnly){
        (parentViewController?.parentViewController as! MainViewController).errandSelection.append(place.description)
            }
            else{
                (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(place.description, atIndex: 0)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)

        
    }
    //if you click the X on the autocomplete modal, this gets called NJK
    func placeViewClosed() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}