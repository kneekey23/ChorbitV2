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
import SystemConfiguration

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    //any declarations of the class go up here like usual NJK
    //IBActions are actions connected with clicks or touches on the UI. IBOutlets are just variable names for things on the UI so you can refer to it. NJK    
    var myGeoLocatedCoords: CLLocation = CLLocation()
    var isAddressOnly: Bool = false;
    var addressString : String = ""
    var clickedChangeStartingLocation: Bool = false
    var clickedDestinationToggle: Bool = false
  
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
        
        self.parentViewController!.presentViewController(gpaViewController, animated: true, completion: nil)
    }

    @IBOutlet var destinationToggle: UISwitch!
    @IBOutlet weak var startingLocationControl: UISegmentedControl!
    @IBOutlet weak var errandTableView: UITableView!
    let locMan: CLLocationManager = CLLocationManager()

    @IBAction func launchButton(sender: AnyObject) {
    }
    
    @IBAction func refreshLocation(sender: AnyObject) {
        locMan.startUpdatingLocation()
    }
    
    @IBAction func chooseStartingPoint(sender: AnyObject) {
       
        
        let segmentedControl: UISegmentedControl = sender as! UISegmentedControl
        if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "use new location"{

             clickedChangeStartingLocation = true
            
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
            
            
            self.parentViewController!.presentViewController(gpaViewController, animated: true, completion: nil)
            
        }
        else{

            //grab current location again NJK
            locMan.startUpdatingLocation()
            
        }
        
    }
    
    @IBAction func toggleEndingLocation(sender: AnyObject) {
     
        //gets called when you toggle roundtrip switch and adds the ui text field if switched to off. NJK
        if !(sender as! UISwitch).on
        {
               clickedDestinationToggle = true
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
            
            
            self.parentViewController!.presentViewController(gpaViewController, animated: true, completion: nil)
        }
        else{
            let lastIndex:Int = (parentViewController?.parentViewController as! MainViewController).errandSelection.count-1
            
            if (parentViewController?.parentViewController as! MainViewController).errandSelection[lastIndex].isEndingLocation{
                (parentViewController?.parentViewController as! MainViewController).errandSelection.removeAtIndex(lastIndex)
                errandTableView.reloadData()
            }
        }

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //reloads TableData when you return to page in case you updated from another page. NJK

        self.errandTableView.reloadData()
        
        
       // locMan.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errandTableView.tableFooterView = UIView()
        
        let logo = UIImage(named: "LogoTitleBar.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        locMan.delegate = self
        locMan.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locMan.requestWhenInUseAuthorization()
        locMan.startUpdatingLocation()
        //this gets rid of ui issue where image blocks line from showing up completely NJK
        if(self.errandTableView != nil){
            // self.errandTableView!.separatorInset = UIEdgeInsetsZero;
            self.errandTableView.reloadData()
        }
        if Reachability.isConnectedToNetwork() == false {
                DisplayErrorAlert("you are not currently connected to any internet connection. please connect to a wifi network to use Chorbit.")
        
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
              DisplayErrorAlert("Location services for Chorbit are not currently turned on. Please turn them on to allow Chorbit to grab your current location or start from another location.")
                   startingLocationControl.selectedSegmentIndex = 1
            case .AuthorizedAlways, .AuthorizedWhenInUse: break
                
            default: break
                
                
            }
        } else {
             DisplayErrorAlert("Location services for Chorbit are not currently turned on. Please turn them on to allow Chorbit to grab your current location or start from another location.")
               startingLocationControl.selectedSegmentIndex = 1
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
        
        let errandLastItemIndex = (parentViewController?.parentViewController as! MainViewController).errandSelection.count - 1
        let errand: Errand = (parentViewController?.parentViewController as! MainViewController).errandSelection[indexPath.row]
            // Configure the cell
             var image : UIImage?
        if(indexPath.row == 0 && errand.isStartingLocation){
            cell.textLabel!.text = "Start: " + errand.errandString
             image = UIImage(named: "Compass-32")!
        }
        else if(errandLastItemIndex == indexPath.row && !self.destinationToggle.on && errand.isEndingLocation){
            cell.textLabel!.text = "End: " + errand.errandString
             image = UIImage(named: "Flag Filled -32")!
        }
        else if(!errand.isStartingLocation && !errand.isEndingLocation){
             cell.textLabel!.text = errand.errandString
             image = UIImage(named: "Geo-fence Filled-25")!
        }
    
        if image != nil{
            cell.imageView!.image = image
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if !(parentViewController?.parentViewController as! MainViewController).errandSelection[indexPath.row].isStartingLocation{
            return true
        }
        else{
            return false
        }

    }

    //so you can delete errands and locations NJK
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            if !(parentViewController?.parentViewController as! MainViewController).errandSelection[indexPath.row].isStartingLocation {
                
                if (parentViewController?.parentViewController as! MainViewController).errandSelection[indexPath.row].isEndingLocation{
                    self.destinationToggle.on = true
                }
                
                (parentViewController?.parentViewController as! MainViewController).errandSelection.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
         
         
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation: CLLocation = locations[0] as CLLocation
        let geocoder: CLGeocoder = CLGeocoder()
        //if horizontal accuracy is greater than 0 we have a better chance of grabbing the most accurate location NJK
        if newLocation.horizontalAccuracy >= 0 {
            myGeoLocatedCoords = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            
           // print(String(myGeoLocatedCoords.coordinate.latitude) + " " + String(myGeoLocatedCoords.coordinate.longitude));
            
            geocoder.reverseGeocodeLocation(myGeoLocatedCoords,
                completionHandler: { (array:[CLPlacemark]?, error:NSError?) -> Void in
              
                    if(array != nil && array!.count > 0){
                        let myPlacemark: CLPlacemark = array![0]
                    
            
                    if myPlacemark.subThoroughfare != nil {
                        self.addressString = myPlacemark.subThoroughfare! + " "
                    }
                    if myPlacemark.thoroughfare != nil {
                        self.addressString = self.addressString + myPlacemark.thoroughfare! + ", "
                    }
                    if myPlacemark.locality != nil {
                        self.addressString = self.addressString + myPlacemark.locality! + ", "
                    }
                    if myPlacemark.administrativeArea != nil {
                        self.addressString = self.addressString + myPlacemark.administrativeArea!
                    }
                    }

                    //delete existing first location if there is one NJK
                    if((self.parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
                        (self.parentViewController?.parentViewController as! MainViewController).errandSelection.removeFirst()
                    }
                    
                    let newStartingLocation: Errand = Errand(errandString: self.addressString, isAddress: true, isStartingLocation: true, isEndingLocation: false)
                       
                    (self.parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newStartingLocation, atIndex: 0)
                    self.errandTableView.reloadData()
                    
            
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
    
    func DisplayErrorAlert(errorMessage: String)
    {
        
        let alertController = UIAlertController(title: "error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "try again", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
            print("Okay was clicked")
        })
        alertController.addAction(okAction)
        
        self.parentViewController!.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if Reachability.isConnectedToNetwork() == true {
            
            if (parentViewController?.parentViewController as! MainViewController).errandSelection.count < 1{
                DisplayErrorAlert("please enter a starting location to launch your route.")
                return false
            }
            else if(parentViewController?.parentViewController as! MainViewController).errandSelection.count < 2 || (parentViewController?.parentViewController as! MainViewController).errandSelection.count < 3 && !self.destinationToggle.on
            {
                DisplayErrorAlert("please enter at least one errand to launch your route.")
                return false
                
            }
            else{
                return true
            }
            
            
        } else {
            
            DisplayErrorAlert("You are not currently connected to any internet connection. Please connect to a wifi network to use Chorbit.")
            return false
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "searchToMapIndentifier"{
            let mapViewController = segue.destinationViewController as! MapViewController
            mapViewController.firstViewController = self
            
    }

    }
}

//extension methods of our controller that get called by the autocomplete class NJK
extension SearchViewController: GooglePlacesAutocompleteDelegate {
    //when you pick something on autocomplete this gets called. NJK
    func placeSelected(place: Place) {
        var error: Bool = false
       let alertController = UIAlertController(title: "error", message: "no more than 5 locations can be routed at this time. coming soon!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
            print("Okay was clicked")
        })
        
        alertController.addAction(okAction)
        
        var totalNumberOfErrands: Int = (parentViewController?.parentViewController as! MainViewController).errandSelection.count - 1
        
        if(!self.destinationToggle.on){
           totalNumberOfErrands = totalNumberOfErrands - 1
        }
        
  
   
        if(!place.isAddressOnly && !clickedChangeStartingLocation && !clickedDestinationToggle){
            if( totalNumberOfErrands < 5){
                if(!self.destinationToggle.on){
                    let lastErrandIndex: Int = (parentViewController?.parentViewController as! MainViewController).errandSelection.count-1
                    if(place.isContact){
                        let newAddress = Errand(errandString: place.contactAddress!, isAddress: true, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newAddress, atIndex: lastErrandIndex)
                    }
                    else if(place.isErrandAddress){
                        let newErrandAddress = Errand(errandString: place.description, isAddress: true, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newErrandAddress, atIndex: lastErrandIndex)
                    }
                    else{
                        let newErrand = Errand(errandString: place.description, isAddress: false, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newErrand, atIndex: lastErrandIndex)
                    }
                    
                    
                }else{
                    
                    if(place.isContact){
                        let newAddress = Errand(errandString: place.contactAddress!, isAddress: true, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.append(newAddress)
                    }
                    else if(place.isErrandAddress){
                        let newErrandAddress = Errand(errandString: place.description, isAddress: true, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.append(newErrandAddress)
                    }
                    else{
                        let newErrand = Errand(errandString: place.description, isAddress: false, isStartingLocation: false, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.append(newErrand)
                    }
                    
                    
                }
            }
            else{
                error = true
            }
        }
            else{
                let lastIndex: Int = (parentViewController?.parentViewController as! MainViewController).errandSelection.count
                if(!self.destinationToggle.on && !clickedChangeStartingLocation && clickedDestinationToggle){
                    if(place.isContact){
                        let newEndingLocation: Errand = Errand(errandString: place.contactAddress!, isAddress: true, isStartingLocation: false, isEndingLocation: true)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newEndingLocation, atIndex: lastIndex)
                        
                    }else{
                        let newEndingLocation: Errand = Errand(errandString: place.description, isAddress: true, isStartingLocation: false, isEndingLocation: true)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newEndingLocation, atIndex: lastIndex)
                    }
                    
                }
                else{
                    if(place.isContact){
                        if((parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
                            (parentViewController?.parentViewController as! MainViewController).errandSelection.removeFirst()
                        }
                        let newStartingLocation: Errand = Errand(errandString: place.contactAddress!, isAddress: true, isStartingLocation: true, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newStartingLocation, atIndex: 0)
                        
                    }else{
                        if((parentViewController?.parentViewController as! MainViewController).errandSelection.count > 0){
                            (parentViewController?.parentViewController as! MainViewController).errandSelection.removeFirst()
                        }
                        let newStartingLocation: Errand = Errand(errandString: place.description, isAddress: true, isStartingLocation: true, isEndingLocation: false)
                        (parentViewController?.parentViewController as! MainViewController).errandSelection.insert(newStartingLocation, atIndex: 0)
                    }
                   
                }
               
            }
      
        
 
        clickedChangeStartingLocation = false
        clickedDestinationToggle = false
        self.parentViewController!.dismissViewControllerAnimated(true, completion: { if error {self.parentViewController!.presentViewController(alertController, animated: true, completion: nil)}})

        
    }
    //if you click the X on the autocomplete modal, this gets called NJK
    func placeViewClosed() {
        if(clickedChangeStartingLocation){
            clickedChangeStartingLocation = false
            startingLocationControl.selectedSegmentIndex = 0
        }
        if(clickedDestinationToggle){
            clickedDestinationToggle = false
            destinationToggle.on = true
        }
        
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
}