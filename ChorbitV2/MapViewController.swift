//
//  MapViewContrller.swift
//  ChorbitV2
//
//  Created by Nicki on 11/29/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var firstViewController : SearchViewController? = nil

    var origin: Coordinates?
    var destination: Coordinates?
    var noResults: [String] = []
    var locationResults: [ErrandResults] = []
    var numErrands: Int = 0
    var closestLocationsPerErrand:[[Coordinates]] = [[]]
    var currentRouteLocations: [Coordinates?] = []
    var _isRoundTrip: Bool = true
    var mapErroredOut: Bool = false
    
    var noresultsAlertController: UIAlertController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myLocation: CLLocation = (firstViewController!.myGeoLocatedCoords) as CLLocation!
        let camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom:6)

        let mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera:camera)
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "Marker Filled-25")
        marker.map = mapView
        GetLocationInformation()
        self.view.addSubview(mapView)
    }
    
    func GetLocationInformation() {
        var lat: Double = 0
        var lng: Double = 0
        var subtitle:String? = ""
        let segmentedControl = (firstViewController!.startingLocationControl)! as UISegmentedControl
        
         if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "Use New Location"{
            
            let addressString: String = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[0]
            let result: Coordinates = GetLatLng(addressString)
            
            if(result.lat > 0){
                lat = result.lat
                lng = result.long
                subtitle = result.subtitle
            }
        }
         else{
            lat = firstViewController!.myGeoLocatedCoords.coordinate.latitude
            lng = firstViewController!.myGeoLocatedCoords.coordinate.longitude
            subtitle = (firstViewController!.addressString)
            
        }
        //latlng = String(format: "%02d,%02d", lat, lng)
        origin = Coordinates(lat: lat, long: lng, title: "My starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil)
        
        if(firstViewController!.destinationToggle as UISwitch).on{
            destination = origin
        }
        else{
              //geocode last item in errand selection array to find the coordinates NJK
            let index: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
            let destinationString = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[index - 1]
                destination = GetLatLng(destinationString)
                destination!.title = "My Final Destination"
          
        }
        locationResults.removeAll()
        closestLocationsPerErrand.removeAll()
        noResults.removeAll()
        var haveFoundLocations: Bool = false
        
        do{
            
            numErrands = 0
            for(var i = 0; i < (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count; i++){
                
                let totalNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
                if totalNumberOfErrands == 0 || i == 0 || i == (totalNumberOfErrands - 1) {
                    continue
                }
                
                numErrands++
                let errandString: String = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[i]
                let location = CLLocationCoordinate2D(latitude: lat, longitude:lng)
                var l: NearbySearch?
                fetchPlacesNearCoordinate(location, name:errandString ) { (data, error) -> Void in
                    do{
                        if(data != nil){
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary {
                            
                            l =  NearbySearch(json as! [String : AnyObject])
                        }
                        }
                        else{
                            print(error)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
                
                
                if(l == nil || l!.results.count == 0){
                    continue
                }
                
                let errandTermId: Int = i
                
                if !errandString.isEmpty{
                    let closestLocations: [Coordinates] = GetClosestLocationsForErrand(l!, errandTermId: errandTermId , errandText: errandString, excludedPlaceIds: nil )
                    
                    if closestLocations.count > 0{
                        closestLocationsPerErrand += closestLocations
                        let usedPlaceIds: [String] = []
                        locationResults.append(ErrandResults(searchResults: l!, errandTermId: errandTermId, usedPlaceIds: usedPlaceIds, errandText: errandString))
                            haveFoundLocations = true
                    }
                }
                
                
            }
            if !haveFoundLocations {
                let locationsNotFound: String = "Unable to find locations for your errands. Please go back and try again."
                mapErroredOut = true
                DisplayErrorAlert(locationsNotFound)
                return
            }
            
            //create route insert here
            
            let buttonRect: UIButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.maxY - 55, width: self.view.frame.width, height: 55))
            buttonRect.setTitle("DIRECTIONS", forState: UIControlState.Normal)
            buttonRect.layer.borderWidth = 1
            //set font here
            buttonRect.layer.borderColor = UIColor(hexString: "#64D8C4").CGColor
            buttonRect.backgroundColor = UIColor(hexString: "#64D8C4")
            buttonRect.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
            self.view.addSubview(buttonRect)
            //buttonRect.targetForAction(<#T##action: Selector##Selector#>, withSender: <#T##AnyObject?#>)
        }
        catch{
            print(error)
            DisplayErrorAlert(error as! String)
        }
        
        
    }
    
    func GetClosestLocationsForErrand(search: NearbySearch, errandTermId: Int, errandText: String, excludedPlaceIds: [String]?) -> [Coordinates]{
      
        var closestLocations: [Coordinates] = []
      
  
 
            var maxResults: Int = 7
            if search.results.count > 0{
              
                if(search.results.count < maxResults){
                    maxResults = search.results.count
                }
            }
            //TODO: work on filtering with swift. NJK
            let filteredResults: [Results] = search.results
            
            for result in filteredResults {
                if maxResults < 1 {
                    break
                }
                if(excludedPlaceIds!.count > 0){
                    var isExcluded: Bool = false
                    for id in excludedPlaceIds!{
                        if id == result.place_id{
                            isExcluded = true
                            continue
                        }
                    }
                    if(isExcluded){
                        continue
                    }
                }
                
                closestLocations.append(Coordinates(lat: result.geometry.location.lat, long: result.geometry.location.lng, title: result.name, subtitle: result.vicinity, errandTermId: errandTermId, placeId: result.place_id, errandText: errandText, errandOrder: nil))
                
                maxResults--
                
            
        }
        if closestLocations.count < 1{
            noResults.append(errandText)
        }

        return closestLocations
       
   }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, name: String, completionHandler: ((NSData!, NSError!) -> Void)){
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDouP4A3_XqFdHn05S0u-f6CxBX0256ZtU&location=\(coordinate.latitude),\(coordinate.longitude)&rankby=distance&sensor=true"
        urlString += "&name=\(name)"
        
        //urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        print(urlString)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

            let session = NSURLSession.sharedSession()
    
            let sessionTask = session.dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
              
                dispatch_async(dispatch_get_main_queue()) {
                    if(data != nil){
                        completionHandler(data, error)
                    }
                    else{
                        completionHandler(nil, error)
                    }
                    
                }
            }
    
           sessionTask.resume()
    }
    
    func GetLatLng(address:String) -> Coordinates{
         let geocoder: CLGeocoder = CLGeocoder()
        let coords: Coordinates = Coordinates()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
            
            if(placemarks!.count > 0){
            let placemark: CLPlacemark = placemarks![0]
            
                
                coords.lat = placemark.location!.coordinate.latitude
                coords.long = placemark.location!.coordinate.longitude
                coords.subtitle = placemark.name!
            }
            
        
        })
        return coords
    }
    
    func CreateRoute()
    {
        var locations: [Coordinates?] = [Coordinates()]
        locations.append(origin)
        
        do {
            //Only hit up mapquest api for optimized route if there are 2 or more errands
            if (closestLocationsPerErrand.count > 1) {
//                HomegrownRouteService routeService = new HomegrownRouteService ();
//                currentRouteLocations = routeService.GetOptimizedRoute (origin, closestLocationsPerErrand, destination);
                
                if(currentRouteLocations.count < 1) {
                    let errandsNotFound: String = "Unable to find locations for your errands. Please go back and try again."
                    DisplayErrorAlert(errandsNotFound)
                    mapErroredOut = true;
                    return;
                }
                
                locations += currentRouteLocations;
            } else {
                //This just means that there's only one errand
                for locationList in closestLocationsPerErrand {
                    if(locationList.count > 0) {
                        locations.append(locationList[0]);
                        currentRouteLocations = locationList;
                        break;
                    }
                }
            }
            
        } catch {
            DisplayErrorAlert("");
        }
        
        if (!_isRoundTrip) {
            locations.append(destination);
        }
        
        var errandCount: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
        
        for (index, value) in locations.enumerate() {
            let errandText: String = value!.errandText.uppercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            var locationTitle: String = value!.title
            // Temporary fix: in future move to filter method and add filters for other known title issues
            if (errandText == "CVS" && locationTitle.characters.count > 3 && locationTitle.uppercaseString.containsString("CVS")) {
                locationTitle = "CVS";
            }
            if (errandText == "CVS" && locationTitle.uppercaseString.containsString("ATM")) {
                locationTitle = "CVS";
            }
            
//            _errandLocations.append(new BasicMapAnnotation (new CLLocationCoordinate2D(value.lat, value.long),
//                locationTitle, value.subtitle, value.placeId, value.errandText, index));
            
            if (noResults.count > 0) {
                var noResultsMsg: String = ""
                for nr in noResults {
                    //Create Alert
                    if (!nr.isEmpty) {
                        noResultsMsg += nr + " did not return any results. "
                    }
                    
                }
                noresultsAlertController = UIAlertController(title: "No Results Found", message: noResultsMsg, preferredStyle: UIAlertControllerStyle.Alert)
                let tryAgainAction = UIAlertAction(title: "Go Back and Re-enter", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
                //Add Actions
                if (noResults.count != numErrands) {
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                        print("Okay was clicked")
                    })
                    
                    noresultsAlertController.addAction(okAction)
                    noresultsAlertController.addAction(tryAgainAction)
                    
                } else {
                    mapErroredOut = true;
                    noresultsAlertController.addAction(tryAgainAction)
                }
                
            }
            
            //Create Origin and Dest Place Marks and Map Items to use for directions
            var emptyDict = NSDictionary()
            
//            if (AddressPage.roundTripSwitch.IsToggled && _errandLocations.Count > 0) {
//                _errandLocations.append(_errandLocations[0]);
//            }
            
            var totalDistance: Double = 0.0
            var routeDistance: Double = 0.0
            var travelTime: Double = 0.0
            var responsesAwaiting: Int = 0
            var allRequestsSent: Bool = false
            var directionRequests: Int //= _errandLocations.count - 1;
            var listGroupDict = [Int: [DirectionStep]]()
            
//            for (index, value) in directionRequests.enumerate() { 
            for var i = 0; i < directionRequests; i++ {
//                var originPlaceMark = MKPlacemark(_errandLocations[i].Coordinate, emptyDict)
//                var sourceItem = MKMapItem(originPlaceMark)
//                
//                var destPlaceMark = new MKPlacemark (_errandLocations [i + 1].Coordinate, emptyDict);
//                var destItem = new MKMapItem (destPlaceMark);
//                
//                var request = new MKDirectionsRequest {
//                    Source = sourceItem,
//                    Destination = destItem
//                };
//                
//                var directions = new MKDirections (request);
                
                //Keep track of response count in async call
                responsesAwaiting++
                if (i == directionRequests - 1) {
                    allRequestsSent = true;
                }
                
                do {
//                    GetDirections(directions, i);
                } catch {
                    DisplayErrorAlert("");
                }
                
            }
            
            if (_errandLocations.count == 0) {
                let locationsNotFound: String = "Unable to find locations for your errands. Please go back and try again."
                DisplayErrorAlert(locationsNotFound)
                mapErroredOut = true
                return
            }
            
            //TODO: move region code to a new method
//            CLLocationCoordinate2D mapCenter = new CLLocationCoordinate2D (_errandLocations[1].Coordinate.Latitude, _errandLocations[1].Coordinate.Longitude);
//            MKCoordinateRegion mapRegion = GetRegionForAnnotations (_errandLocations, mapCenter);
//            map.CenterCoordinate = mapCenter;
//            map.Region = mapRegion;
            
            //Present Alert
            if (noResults.count > 0) {
                self.presentViewController(noresultsAlertController, animated: true, completion: nil)
            }
        }
    }
    
    func DisplayErrorAlert(var errorMessage: String)
    {
        if(errorMessage.isEmpty){
            mapErroredOut = true
            errorMessage = "We are sorry. It seems a meteorite hit the app at an unexpected pace. Please try landing your spaceship and relaunching."
        }
        
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        alertController.addAction(tryAgainAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

}
