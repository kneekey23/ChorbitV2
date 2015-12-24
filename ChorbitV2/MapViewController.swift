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
import Alamofire
import Polyline

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var firstViewController : SearchViewController? = nil
    
    var mapView: GMSMapView?
    var origin: Coordinates?
    var destination: Coordinates?
    var noResults: [String] = []
    var locationResults: [ErrandResults] = []
    var numErrands: Int = 0
    var closestLocationsPerErrand:[[Coordinates]] = [[]]
    var _errandLocations: [BasicMapAnnotation] = []
    var currentRouteLocations: [Coordinates?] = []
    var _isRoundTrip: Bool = true
    var mapErroredOut: Bool = false
    
    var placeResponsesAwaiting: Int = 0;
    var allPlaceRequestsSent: Bool = false;
    
    var totalDistanceMeters: Int = 0
    var totalDistanceMiles: Double = 0.0
    var routeDistance: Double = 0.0
    var durationSeconds: Int = 0
    var listGroupDict = [Int: [DirectionStep]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myLocation: CLLocation = (firstViewController!.myGeoLocatedCoords) as CLLocation!
        let camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom:6)

        mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera:camera)
        mapView!.delegate = self
        GetLocationInformation()
        self.view.addSubview(mapView!)
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
            
            let totalNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
            numErrands = 0
            placeResponsesAwaiting = 0;
            self.allPlaceRequestsSent = false;
            
            for(var i = 0; i < totalNumberOfErrands; i++){
                
                if totalNumberOfErrands == 0 || i == 0 {
                    continue
                }
                
                numErrands++
                let errandString: String = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[i]
                let location = CLLocationCoordinate2D(latitude: lat, longitude:lng)
                var l: NearbySearch?
                
                // Keeping track of async requests and responses
                placeResponsesAwaiting++
                if i == totalNumberOfErrands - 1{
                    self.allPlaceRequestsSent = true
                }
                
                fetchPlacesNearCoordinate(location, name:errandString, count: i) { (data, error, count) -> Void in
                    do{
                        if(data != nil){
                            self.placeResponsesAwaiting--
                            
                            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary {
                                
                                l =  NearbySearch(json as! [String : AnyObject])
                                
                                if(l != nil || l!.results.count != 0){
                                    
                                    
                                    
                                    let errandTermId: Int = count
                                    
                                    if !errandString.isEmpty{
                                        let closestLocations: [Coordinates] = self.GetClosestLocationsForErrand(l!, errandTermId: errandTermId , errandText: errandString, excludedPlaceIds: nil )
                                        
                                        if closestLocations.count > 0{
                                            self.closestLocationsPerErrand.append(closestLocations)
                                            let usedPlaceIds: [String] = []
                                            self.locationResults.append(ErrandResults(searchResults: l!, errandTermId: errandTermId, usedPlaceIds: usedPlaceIds, errandText: errandString))
                                            haveFoundLocations = true
                                        }
                                    }
                                    
                                    if !haveFoundLocations {
                                        let locationsNotFound: String = "Unable to find locations for your errands. Please go back and try again."
                                        self.mapErroredOut = true
                                        self.DisplayErrorAlert(locationsNotFound)
                                        return
                                    }
                                    
                                    if(self.allPlaceRequestsSent && self.placeResponsesAwaiting == 0){
                                        self.CreateRoute()
                                    }
                                    
                                }
                            }
                        }
                        else{
                            print(error)
                        }
                    
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
                

            }
         
          
            
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
                if excludedPlaceIds != nil && excludedPlaceIds!.count > 0 {
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
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, name: String, count: Int, completionHandler: ((NSData!, NSError!, count: Int) -> Void)){
        
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDouP4A3_XqFdHn05S0u-f6CxBX0256ZtU&location=\(coordinate.latitude),\(coordinate.longitude)&rankby=distance&sensor=true"
        urlString += "&name=\(name)"

        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let session = NSURLSession.sharedSession()
    
        let sessionTask = session.dataTaskWithURL(NSURL(string: urlString)!) { data, response, error in
              
                dispatch_async(dispatch_get_main_queue()) {
                    if(data != nil){
                        completionHandler(data, error, count: count)
                    }
                    else{
                        completionHandler(nil, error, count: count)
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
        var locations: [Coordinates?] = []
        locations.append(origin)
        
        do {
            //Only hit up mapquest api for optimized route if there are 2 or more errands
            if (closestLocationsPerErrand.count > 1) {
//                HomegrownRouteService routeService = new HomegrownRouteService ();
//                currentRouteLocations = routeService.GetOptimizedRoute (origin, closestLocationsPerErrand, destination);
                
                // TODO: Remove this hardcoded crap thats only here instead of calling HomegrownRouteService:
                for locationList in closestLocationsPerErrand {
                    currentRouteLocations.append(locationList[0])
                }
                
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
                locationTitle = "CVS"
            }
            if (errandText == "CVS" && locationTitle.uppercaseString.containsString("ATM")) {
                locationTitle = "CVS"
            }
            // End Temporary fix
            
            _errandLocations.append(BasicMapAnnotation(coordinate: CLLocationCoordinate2DMake(value!.lat, value!.long), title: locationTitle, snippet: value!.subtitle, placeId: value!.placeId, errandText: value!.errandText, errandOrder: index))
        }
            
            var noresultsAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
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
//            var emptyDict = NSDictionary()
        
            if (_isRoundTrip && _errandLocations.count > 0) {
                _errandLocations.append(_errandLocations[0])
            }
        
//            let waypoints = _errandLocations[2..._errandLocations.count - 1]
        
            var url = "https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY&origin=\(_errandLocations[0].position.latitude),\(_errandLocations[0].position.longitude)&destination=\(_errandLocations[1].position.latitude),\(_errandLocations[1].position.longitude)&waypoints="
        
            for var i = 2; i < _errandLocations.count; i++ {
                url += "\(_errandLocations[i].position.latitude),\(_errandLocations[i].position.longitude)"
                if(i != _errandLocations.count - 1) {
                    url += "|"
                }
            }
        
            url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
            do {
                GetDirections(url);
            } catch {
                DisplayErrorAlert("");
            }
            
            if (_errandLocations.count == 0) {
                let locationsNotFound: String = "Unable to find locations for your errands. Please go back and try again."
                DisplayErrorAlert(locationsNotFound)
                mapErroredOut = true
                return
            }
            
            //Present Alert
            if (noResults.count > 0) {
                self.presentViewController(noresultsAlertController, animated: true, completion: nil)
            }
    }
    
    func GetDirections(url: String)
    {
        var temp: [DirectionStep] = []
        Alamofire.request(.GET, url)
            .responseJSON { response in
                
                if let json = response.result.value {
                    let directionsResponse: GoogleDirectionsResponse = GoogleDirectionsResponse(json as! [String : AnyObject])
                    
                    for route in directionsResponse.routes {
                        var polylinePts: String = ""
//                        if (route.overview_polyline != nil) {
                            polylinePts = route.overview_polyline.points
//                        }
                        
                        if (!polylinePts.isEmpty) {
                            let polylineCoords: [CLLocationCoordinate2D]? = decodePolyline(polylinePts)
                            
                            let path = GMSMutablePath()
                            for polylineCoord in polylineCoords! {
                                path.addCoordinate(polylineCoord)
                            }
                                
                            let polyline = GMSPolyline(path: path)
                            // TODO: figure out how to initialize mapView as global class variable:
                            polyline.map = self.mapView
                        }
                        
                        // Bounds contains the viewport bounding box of the overview_polyline
                        let southwest = CLLocationCoordinate2DMake(route.bounds.southwest.lat, route.bounds.southwest.lng)
                        let northeast = CLLocationCoordinate2DMake(route.bounds.northeast.lat, route.bounds.northeast.lng)
                        let bounds = GMSCoordinateBounds(coordinate: southwest, coordinate: northeast)
                        let padding = CGFloat(30)
                        let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
                        self.mapView!.animateWithCameraUpdate(fitBounds)
                        
                        
                        for leg in route.legs {
//                            if (leg.distance != nil) {
                                self.totalDistanceMeters += leg.distance.value
//                            }
                            
//                            if(leg.duration_in_traffic && leg.duration_in_traffic.value) {
//                                durationSeconds += leg.duration_in_traffic.value
//                            } else if(leg.duration && leg.duration.value) {
                                self.durationSeconds += leg.duration.value
//                            }
                            
                            var instructionIndex: Int = 1;
                            for step in leg.steps {
                                let directionStep: DirectionStep = DirectionStep()
//                                directionStep.errandGroupNumber = string.Format ("{0} {1}", "To", _errandLocations [i + 1].Title);
//                                directionStep.directionText = step.html_instructions;
                                directionStep.stepIndex = instructionIndex;
                                if(instructionIndex != 1)
                                {
                                    directionStep.distance = step.distance.value
                                    directionStep.duration = step.duration.value
                                }
                                
                                temp.append(directionStep);
                                instructionIndex++;
                            }
                        }
                        
                        // TODO: Add all steps to directions page
                        
                        
                        
                        
                        // accomplishing 1 decimal place with * 10 / 10
                        self.totalDistanceMiles = Double(round(Double(self.totalDistanceMeters) * 0.000621371 * 10)/10)
//                        let timeInt: Int = round(self.durationSeconds / 60)
                        let timeInt: Int = self.durationSeconds / 60
                        var timeText: String = ""
                        var hrs: Int = 0
                        var mins: Int = self.durationSeconds
                        var boxWidth: Double = Double(UIScreen.mainScreen().bounds.width) - 140
                        if (self.durationSeconds >= 60) {
                            let hrsDecimal: Double = Double(timeInt) / 60
                            hrs = Int(floor(hrsDecimal))
                            mins = timeInt - (hrs * 60);
                            timeText = String(hrs) + " hr " + String(mins) + " min";
                            boxWidth = Double(UIScreen.mainScreen().bounds.width) - 125;
                        } else {
                            timeText = String(mins) + " min";
                        }
                        
                        
                        // TODO: Add infoOverlay with distance and duration here
                        
            
                        
                        for routeLocation in self._errandLocations {
                            // Add markers to map:
                            let marker = GMSMarker()
                            marker.position = routeLocation.position
                            marker.title = routeLocation.title
                            marker.snippet = routeLocation.snippet
                            marker.appearAnimation = kGMSMarkerAnimationPop
                            marker.icon = UIImage(named: "Marker Filled-25")
                            // TODO: figure out how to initialize mapView as global class variable:
                            marker.map = self.mapView
                        }
                        
                        // Only interested in routes[0] right now
                        break;
                    }
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
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }

}
