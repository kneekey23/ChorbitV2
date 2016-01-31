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
import SwiftyJSON
import ObjectMapper

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var firstViewController : SearchViewController? = nil
    
    var mapView: GMSMapView?
    var noResults: [String] = []
    var numErrands: Int = 0
    var temp: [DirectionStep] = []
    var selectedMarker: GoogleMapMarker = GoogleMapMarker()
    var errandAddress: Coordinates?
    var transportModeHasChanged = false
    
    var placeResponsesAwaiting: Int = 0
    var allPlaceRequestsSent: Bool = false
    var loadingAlertIsDisplayed: Bool = false
    
    var totalDistanceMeters: Int = 0
    var totalDistanceMiles: Double = 0.0
    var routeDistance: Double = 0.0
    var durationSeconds: Int = 0
    var listGroupDict = [Int: [DirectionStep]]()
    var progressBackground: UIImageView?
    var progress: UInt8 = 0
    
    struct Static {
        static var origin: Coordinates?
        static var destination: Coordinates?
        static var modeOfTransportation: String = "driving"
        static var cachedRoutes = [String: [GoogleMapMarker]]()
        static var cachedPaths = [String: GMSMutablePath]()
        static var closestLocationsPerErrand:[[Coordinates]] = [[]]
        static var cachedCurrentRouteLocations = [String: [Coordinates?]]()
        static var locationResults: [ErrandResults] = []
        static var _isRoundTrip: Bool = true
        static var cachedInfoOverlays = [String: UITextView!]()
        static var mapErroredOut: Bool = false
        static var cachedDirectionsGrouped = [String: [[DirectionStep]]]()
        static var cachedBounds = [String: GMSCoordinateBounds?]()
    }
    
    @IBOutlet weak var transportationTyoe: UISegmentedControl!
    @IBOutlet weak var buttonRect: UIButton!
    @IBAction func refreshTrafficConditions(sender: AnyObject) {
        mapView?.clear()
        if let viewWithTag = self.view.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
            Static.cachedInfoOverlays[Static.modeOfTransportation] = nil
             self.durationSeconds = 0
             self.totalDistanceMeters = 0
        }
        
        Static.cachedPaths = [Static.modeOfTransportation: GMSMutablePath()]
        Static.mapErroredOut = false
        Static.cachedDirectionsGrouped = [Static.modeOfTransportation: [[]]]
        Static.cachedRoutes = [Static.modeOfTransportation: []]
        Static.cachedCurrentRouteLocations = [Static.modeOfTransportation: []]
        self.CreateRoute()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Static.modeOfTransportation = "driving"
        
        // Caching
        let totalNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
        let prevNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).prevErrandSelection.count
        
        var recalc = false
        if totalNumberOfErrands != prevNumberOfErrands || prevNumberOfErrands == 0 || Static.mapErroredOut {
            recalc = true;
        }
        
        if !recalc {
            for(var i = 0; i < totalNumberOfErrands; i++){
                let errand: Errand = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[i]
                let prevErrand: String = (firstViewController?.parentViewController?.parentViewController as! MainViewController).prevErrandSelection[i]
                
                if errand.errandString != prevErrand {
                    recalc = true
                    break
                }
            }
        }
        
        var isRoundTrip = false;
        if(self.firstViewController!.destinationToggle as UISwitch).on{
            isRoundTrip = true;
        }
        if isRoundTrip != Static._isRoundTrip {
            recalc = true
        }
        if Static.cachedRoutes.isEmpty {
            recalc = true
        }
        // End caching
        
        let myLocation: CLLocation = (firstViewController!.myGeoLocatedCoords) as CLLocation!
        let camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom:6)

        mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera:camera)
        mapView!.delegate = self
      
        self.view.addSubview(mapView!)
        self.view.addSubview(buttonRect)
        self.view.addSubview(transportationTyoe)
        
        if !recalc {
            for routeLocation in Static.cachedRoutes[Static.modeOfTransportation]! {
                // Add cached markers to map:
                let marker = GoogleMapMarker()
                marker.position = routeLocation.position
                marker.placeId = routeLocation.placeId
                marker.title = routeLocation.title
                marker.snippet = routeLocation.snippet
                marker.errandOrder = routeLocation.errandOrder
                marker.isErrand = routeLocation.isErrand
                marker.errandText = routeLocation.errandText
                marker.appearAnimation = kGMSMarkerAnimationPop
                if routeLocation.isErrand {
                    marker.icon = UIImage(named: "Marker Filled-25")
                } else {
                    marker.icon = UIImage(named: "Marker-25-coral")
                }
                marker.map = self.mapView
            }
            
            let polyline = GMSPolyline(path: Static.cachedPaths[Static.modeOfTransportation]!)
            polyline.map = self.mapView
            
            let padding = CGFloat(90)
            let bounds = Static.cachedBounds[Static.modeOfTransportation]!
            let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
            self.mapView!.animateWithCameraUpdate(fitBounds)
            self.mapView?.addSubview(Static.cachedInfoOverlays[Static.modeOfTransportation]!)
            
            if loadingAlertIsDisplayed {
                self.dismissViewControllerAnimated(false, completion: nil)
                loadingAlertIsDisplayed = false
            }
        } else {
            Static.cachedPaths = ["driving": GMSMutablePath()]
            Static.cachedDirectionsGrouped = ["driving": [[]]]
            Static.cachedRoutes = ["driving": []]
            Static.cachedCurrentRouteLocations = ["driving": []]
            Static.mapErroredOut = false
            
            configureLoadingMessage()
            GetLocationInformation()
        }
    }
    
    @IBAction func changeTransportationType(sender: AnyObject) {
        //code to change from driving to walking to transit goes here.NJK
        let segmentedControl: UISegmentedControl = sender as! UISegmentedControl
        var recalc = false
        
        if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "drive"{
            Static.modeOfTransportation = "driving"
        }
        else if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "walk"{
            Static.modeOfTransportation = "walking"
        }
        else{
            Static.modeOfTransportation = "cycling"
        }
        
        if Static.cachedRoutes[Static.modeOfTransportation] == nil {
            recalc = true
        }
        
        mapView?.clear()
        if !recalc {
            for routeLocation in Static.cachedRoutes[Static.modeOfTransportation]! {
                let marker = GoogleMapMarker()
                marker.position = routeLocation.position
                marker.placeId = routeLocation.placeId
                marker.title = routeLocation.title
                marker.snippet = routeLocation.snippet
                marker.errandOrder = routeLocation.errandOrder
                marker.errandText = routeLocation.errandText
                marker.appearAnimation = kGMSMarkerAnimationPop
                if routeLocation.isErrand {
                    marker.icon = UIImage(named: "Marker Filled-25")
                } else {
                    marker.icon = UIImage(named: "Marker-25-coral")
                }
                marker.map = self.mapView
            }
            
            if let viewWithTag = self.view.viewWithTag(99) {
                viewWithTag.removeFromSuperview()
            }
            
            let polyline = GMSPolyline(path: Static.cachedPaths[Static.modeOfTransportation]!)
            polyline.map = self.mapView
            
            let padding = CGFloat(90)
            let bounds = Static.cachedBounds[Static.modeOfTransportation]!
            let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
            self.mapView!.animateWithCameraUpdate(fitBounds)
            self.mapView?.addSubview(Static.cachedInfoOverlays[Static.modeOfTransportation]!)
            if loadingAlertIsDisplayed {
                self.dismissViewControllerAnimated(false, completion: nil)
                loadingAlertIsDisplayed = false
            }
        } else {
            Static.cachedPaths[Static.modeOfTransportation] = GMSMutablePath()
            Static.cachedRoutes[Static.modeOfTransportation] = []
            Static.mapErroredOut = false
            
            if let viewWithTag = self.view.viewWithTag(99) {
                viewWithTag.removeFromSuperview()
                Static.cachedInfoOverlays[Static.modeOfTransportation] = nil
                self.durationSeconds = 0
                self.totalDistanceMeters = 0
            }
            
            Static.cachedDirectionsGrouped[Static.modeOfTransportation] = [[]]
            Static.cachedCurrentRouteLocations[Static.modeOfTransportation] = []
            self.CreateRoute()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToDirectionsSegue"{
            let directionsViewController = segue.destinationViewController as! DirectionsController
            directionsViewController.directions = temp
            directionsViewController.directionsGrouped = Static.cachedDirectionsGrouped[Static.modeOfTransportation]!
            
        }
        
    }
    
    func GetLocationInformation() {
        var lat: Double = 0
        var lng: Double = 0
        var subtitle:String? = ""
        let segmentedControl = (firstViewController!.startingLocationControl)! as UISegmentedControl
        lat = firstViewController!.myGeoLocatedCoords.coordinate.latitude
        lng = firstViewController!.myGeoLocatedCoords.coordinate.longitude
        subtitle = (firstViewController!.addressString)
        Static.origin = Coordinates(lat: lat, long: lng, title: "my starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil, isErrand: false)
         if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "use new location"{
            
            let startingLocation: Errand = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[0]
            let result: Coordinates = Coordinates()
            self.GetLatLng(startingLocation.errandString) { placemarks, error in
                if placemarks != nil {
                    if(placemarks!.count > 0){
                        let placemark: CLPlacemark = placemarks![0]
                        
                        
                        result.lat = placemark.location!.coordinate.latitude
                        result.long = placemark.location!.coordinate.longitude
                        result.subtitle = placemark.name!
                        
                        if(result.lat > 0){
                            lat = result.lat
                            lng = result.long
                            subtitle = result.subtitle
                        }
                        Static.origin = Coordinates(lat: lat, long: lng, title: "my starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil, isErrand: false)
                        
                        if(self.firstViewController!.destinationToggle as UISwitch).on{
                            Static._isRoundTrip = true
                            Static.destination = Static.origin
                            self.BuildRoute(lat, lng: lng)
                        }
                        else{
                            //geocode last item in errand selection array to find the coordinates NJK
                            let index: Int = (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
                            let destinationLocation: Errand = (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[index - 1]
                            Static._isRoundTrip = false
                            self.GetLatLng(destinationLocation.errandString) { placemarks, error in
                                if placemarks != nil {
                                    if(placemarks!.count > 0){
                                        let placemark: CLPlacemark = placemarks![0]
                                        
                                        Static.destination = Coordinates()
                                        Static.destination!.lat = placemark.location!.coordinate.latitude
                                        Static.destination!.long = placemark.location!.coordinate.longitude
                                        Static.destination!.subtitle = placemark.name!
                                        Static.destination!.isErrand = false
                                        Static.destination!.title = "my final destination"
                                        
                                        self.BuildRoute(lat, lng: lng)
                                    }
                                }
                            }
                            
                            
                            
                        }
                    }
                }
            }
            
            
        }
         else{
           
            
            if(self.firstViewController!.destinationToggle as UISwitch).on{
                Static._isRoundTrip = true
                Static.destination = Static.origin
                self.BuildRoute(lat, lng: lng)
            }
            else{
                //geocode last item in errand selection array to find the coordinates NJK
                let index: Int = (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
                let destinationLocation: Errand = (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[index - 1]
                Static._isRoundTrip = false
                self.GetLatLng(destinationLocation.errandString) { placemarks, error in
                    if placemarks != nil {
                        if(placemarks!.count > 0){
                            let placemark: CLPlacemark = placemarks![0]
                            
                            Static.destination = Coordinates()
                            Static.destination!.lat = placemark.location!.coordinate.latitude
                            Static.destination!.long = placemark.location!.coordinate.longitude
                            Static.destination!.subtitle = placemark.name!
                            Static.destination!.title = "my final destination"
                            Static.destination!.isErrand = false
                            
                            self.BuildRoute(lat, lng: lng)
                        }
                    }
                }

            }
        }
        
    }
    
    func BuildRoute(lat: Double, lng: Double){
        
        Static.locationResults.removeAll()
        Static.closestLocationsPerErrand.removeAll()
        noResults.removeAll()
        var haveFoundLocations: Bool = false
        
        // Add errands text for caching
        var totalNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
        (firstViewController?.parentViewController?.parentViewController as! MainViewController).prevErrandSelection.removeAll()
        for(var i = 0; i < totalNumberOfErrands; i++){
            let errand: Errand = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[i]
            (firstViewController?.parentViewController?.parentViewController as! MainViewController).prevErrandSelection.append(errand.errandString)
        }
        
        if !Static._isRoundTrip {
            totalNumberOfErrands -= 1
        }
        
        numErrands = 0
        placeResponsesAwaiting = 0;
        self.allPlaceRequestsSent = false;
        
        for(var i = 0; i < totalNumberOfErrands; i++){
            
            let errand: Errand = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection[i]
            
            if totalNumberOfErrands == 0 || i == 0 {
                continue
            }
            
            // Keeping track of async requests and responses
            placeResponsesAwaiting++
            if i == totalNumberOfErrands - 1{
                self.allPlaceRequestsSent = true
            }
            
            numErrands++
            let location = CLLocationCoordinate2D(latitude: lat, longitude:lng)
            var l: NearbySearch?
            
            //if the errand is not an address and something like Target, fetch closest locations using Google Places API NJK
            
            fetchPlacesNearCoordinate(location, errand:errand, count: i) { (data, error, count) -> Void in
                do{
                    if(data != nil || errand.isAddress){
                        self.placeResponsesAwaiting--
                        if(data != nil){
                            
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                            l =  NearbySearch(json as! [String : AnyObject])
                        }
                        
                        
                        if((l != nil && l!.results.count != 0) || errand.isAddress){
                            
                            
                            let errandTermId: Int = count
                            
                            if !errand.errandString.isEmpty && !errand.isAddress{
                                let closestLocations: [Coordinates] = self.GetClosestLocationsForErrand(l!, errandTermId: errandTermId , errandText: errand.errandString, excludedPlaceIds: nil)
                                
                                if closestLocations.count > 0{
                                    Static.closestLocationsPerErrand.append(closestLocations)
                                    let usedPlaceIds: [String] = []
                                    Static.locationResults.append(ErrandResults(searchResults: l!, errandTermId: errandTermId, usedPlaceIds: usedPlaceIds, errandText: errand.errandString))
                                    haveFoundLocations = true
                                }
                            }
                            else{
                                //else find the coords, add it to an array of coords and add it to the array that goes to the algorithm, closestLocationsPerErrand
                                
                                var addressArray: [Coordinates] = []
                                
                                addressArray.append(self.errandAddress!)
                                Static.closestLocationsPerErrand.append(addressArray)
                                haveFoundLocations = true
                            }
                            
                            if !haveFoundLocations {
                                let locationsNotFound: String = "unable to find locations for your errands. please go back and try again."
                                Static.mapErroredOut = true
                                self.DisplayErrorAlert(locationsNotFound)
                                return
                            }
                            
                            if(self.allPlaceRequestsSent && self.placeResponsesAwaiting == 0){
                                self.CreateRoute()
                            }
                            
                        } else {
                            // No results came back for this location
                            self.noResults.append(errand.errandString)
                            if(self.allPlaceRequestsSent && self.placeResponsesAwaiting == 0){
                                self.CreateRoute()
                            }
                        }
                        
                    }
                    else{
                        self.placeResponsesAwaiting--
                        self.noResults.append(errand.errandString)
                        if(self.allPlaceRequestsSent && self.placeResponsesAwaiting == 0){
                            self.CreateRoute()
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                    Static.mapErroredOut = true
                    self.DisplayErrorAlert("")
                }
                
            }
            
            
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
        // TODO: work on filtering with swift. NJK
        
        var filteredResults: [Results] = []
        var addresses: [String] = []
        for result in search.results {
            if !addresses.contains(result.vicinity) {
                filteredResults.append(result)
                addresses.append(result.vicinity)
            }
        }
        
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
            
            closestLocations.append(Coordinates(lat: result.geometry.location.lat, long: result.geometry.location.lng, title: result.name, subtitle: result.vicinity, errandTermId: errandTermId, placeId: result.place_id, errandText: errandText, errandOrder: nil, isErrand: true))
            
            maxResults--
            
            
        }
        if closestLocations.count < 1{
            noResults.append(errandText)
        }

        return closestLocations
       
   }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, errand: Errand, count: Int, completionHandler: ((NSData!, NSError!, count: Int) -> Void)){
        
        if !errand.isAddress{
            
            var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyDouP4A3_XqFdHn05S0u-f6CxBX0256ZtU&location=\(coordinate.latitude),\(coordinate.longitude)&rankby=distance&sensor=true"
            urlString += "&name=\(errand.errandString)"
            
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
        else{
            GetLatLng(errand.errandString) { placemarks, error in
                
                if(placemarks!.count > 0){
                    let placemark: CLPlacemark = placemarks![0]
                    
                    self.errandAddress = Coordinates()
                    self.errandAddress!.lat = placemark.location!.coordinate.latitude
                    self.errandAddress!.long = placemark.location!.coordinate.longitude
                    self.errandAddress!.subtitle = placemark.name!
                    self.errandAddress!.errandText = errand.errandString
                }
                
                //do nothing becayse it's an address that has been entered as an errand NJK
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(nil, nil, count: count)
                    
                    
                }
            }
            
        }
    }
    
    
    func GetLatLng(address: String, completionHandler: ([CLPlacemark]!, NSError?) -> ()) {
        let geocoder: CLGeocoder = CLGeocoder()
        
        
        geocoder.geocodeAddressString(address) { placemarks, error in
            if error != nil {
                print("geocoding error: \(error)")
            } else if placemarks!.count == 0 {
                print("no placemarks")
            }
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(placemarks!, error)
            }
        }
    }
    
    func CreateRoute()
    {
        Static.cachedCurrentRouteLocations[Static.modeOfTransportation] = []
        var locations: [Coordinates?] = []
        locations.append(Static.origin)

            //Only hit up algorithm for optimized route if there are 2 or more errands
            if (Static.closestLocationsPerErrand.count > 1) {
                let routeServiceUrl = "https://b97482pu3h.execute-api.us-west-2.amazonaws.com/test/ChorbitAlgorithm"
                
                let routeServiceRequest: RouteServiceRequest = RouteServiceRequest(origin: Static.origin!, errands: Static.closestLocationsPerErrand, destination: Static.destination!, mode: Static.modeOfTransportation)
                
                let requestObj: AnyObject = routeServiceRequest
                let JSONString = Mapper().toJSONString(routeServiceRequest)
                let params: [String: AnyObject] = ["request": JSONString!]
                
                Alamofire.request(.POST, routeServiceUrl, parameters: params, encoding: .JSON)
                    .responseJSON { response in
                        
                        if let json = response.result.value {
                            let routeServiceResponse: RouteServiceResponse = RouteServiceResponse(json as! [String : AnyObject])
                            
                            for r in routeServiceResponse.results {
                                //print(r)
                                Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.append(Coordinates?(r))
                            }
                            
                            if(Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.count < 1) {
                                if self.loadingAlertIsDisplayed {
                                    self.dismissViewControllerAnimated(false, completion: nil)
                                    self.loadingAlertIsDisplayed = false
                                }
                                let errandsNotFound: String = "unable to find locations for your errands. please go back and try again."
                                Static.mapErroredOut = true
                                self.DisplayErrorAlert(errandsNotFound)
                                return;
                            }
                            
                            locations += Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!;
                            
                           self.MapResults(locations)
                        }
                }
                
                
                
            } else {
                //This just means that there's only one errand
                for locationList in Static.closestLocationsPerErrand {
                    if(locationList.count > 0) {
                        locations.append(locationList[0]);
                        Static.cachedCurrentRouteLocations[Static.modeOfTransportation] = locations;
                        break;
                    }
                }
                MapResults(locations)
                
            }

        
        
    }
    
    func MapResults(var locations: [Coordinates?]){
        
        if (!Static._isRoundTrip) {
            locations.append(Static.destination);
        }
        
        
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
            
            Static.cachedRoutes[Static.modeOfTransportation]!.append(GoogleMapMarker(coordinate: CLLocationCoordinate2DMake(value!.lat, value!.long), title: locationTitle, snippet: value!.subtitle, placeId: value!.placeId, errandText: value!.errandText, errandOrder: index, isErrand: value!.isErrand))
        }
    
        var noresultsAlertController = UIAlertController(title: nil, message: "", preferredStyle: .Alert)
        if (self.noResults.count > 0) {
            
            var noResultsMsg: String = ""
            for nr in self.noResults {
                //Create Alert
                if (!nr.isEmpty) {
                    noResultsMsg += nr + " did not return any results. "
                }
                
            }
            
            noresultsAlertController = UIAlertController(title: "no results found", message: noResultsMsg, preferredStyle: UIAlertControllerStyle.Alert)
            let tryAgainAction = UIAlertAction(title: "go back and re-enter", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            //Add Actions
            if (self.noResults.count != self.numErrands) {
                let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                    print("Okay was clicked")
                })
                
                noresultsAlertController.addAction(okAction)
                noresultsAlertController.addAction(tryAgainAction)
                
            } else {
                Static.mapErroredOut = true;
                noresultsAlertController.addAction(tryAgainAction)
            }
            
        }
        
        if (Static._isRoundTrip && Static.cachedRoutes[Static.modeOfTransportation]!.count > 0) {
            Static.cachedRoutes[Static.modeOfTransportation]!.append(Static.cachedRoutes[Static.modeOfTransportation]![0])
        }
        
        var modeOfTransport = Static.modeOfTransportation
        if(Static.modeOfTransportation == "cycling"){
            modeOfTransport = "bicycling"
        }
        
        let destIdx = Static.cachedRoutes[Static.modeOfTransportation]!.count - 1;
        
        var url = "https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY&origin=\(Static.cachedRoutes[Static.modeOfTransportation]![0].position.latitude),\(Static.cachedRoutes[Static.modeOfTransportation]![0].position.longitude)&destination=\(Static.cachedRoutes[Static.modeOfTransportation]![destIdx].position.latitude),\(Static.cachedRoutes[Static.modeOfTransportation]![destIdx].position.longitude)&mode=\(modeOfTransport)&waypoints="
        
        for var i = 1; i < Static.cachedRoutes[Static.modeOfTransportation]!.count - 1; i++ {
            url += "\(Static.cachedRoutes[Static.modeOfTransportation]![i].position.latitude),\(Static.cachedRoutes[Static.modeOfTransportation]![i].position.longitude)"
            if(i != Static.cachedRoutes[Static.modeOfTransportation]!.count - 1) {
                url += "|"
            }
        }
        
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        

            self.GetDirections(url);

        
        if (Static.cachedRoutes[Static.modeOfTransportation]!.count == 0) {
            if loadingAlertIsDisplayed {
                self.dismissViewControllerAnimated(false, completion: nil)
                loadingAlertIsDisplayed = false
            }
            let locationsNotFound: String = "unable to find locations for your errands. please go back and try again."
            Static.mapErroredOut = true
            self.DisplayErrorAlert(locationsNotFound)
            return
        }
        
        //Present Alert
        if (self.noResults.count > 0) {
            if loadingAlertIsDisplayed {
                self.dismissViewControllerAnimated(false, completion: nil)
                loadingAlertIsDisplayed = false
            }
            self.presentViewController(noresultsAlertController, animated: true, completion: nil)
        }

    }
    
    func GetDirections(url: String)
    {
       
        Alamofire.request(.GET, url)
            .responseJSON { response in
                
                if let json = response.result.value {
                    let directionsResponse: GoogleDirectionsResponse = GoogleDirectionsResponse(json as! [String : AnyObject])
                    
                    for route in directionsResponse.routes {
                        var polylinePts: String = ""
                            polylinePts = route.overview_polyline.points
                        
                        if (!polylinePts.isEmpty) {
                            let polylineCoords: [CLLocationCoordinate2D]? = decodePolyline(polylinePts)
                            
                            for polylineCoord in polylineCoords! {
                                Static.cachedPaths[Static.modeOfTransportation]!.addCoordinate(polylineCoord)
                            }
                            
                            let polyline = GMSPolyline(path: Static.cachedPaths[Static.modeOfTransportation]!)
                            polyline.map = self.mapView
                        }
                        
                        // Bounds contains the viewport bounding box of the overview_polyline
                        let southwest = CLLocationCoordinate2DMake(route.bounds.southwest.lat, route.bounds.southwest.lng)
                        let northeast = CLLocationCoordinate2DMake(route.bounds.northeast.lat, route.bounds.northeast.lng)
                        let bounds = GMSCoordinateBounds(coordinate: southwest, coordinate: northeast)
                        Static.cachedBounds[Static.modeOfTransportation] = bounds
                        
                        let padding = CGFloat(90)
                        let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
                        self.mapView!.animateWithCameraUpdate(fitBounds)
                        if self.loadingAlertIsDisplayed {
                            self.dismissViewControllerAnimated(false, completion: nil)
                            self.loadingAlertIsDisplayed = false
                        }
                        
                    
                        var legIndex: Int = 1;
                        for leg in route.legs {

                            self.totalDistanceMeters += leg.distance.value

                            self.durationSeconds += leg.duration.value

                            var instructionIndex: Int = 1;
                         
                            var directionsList: [DirectionStep] = []
                            
                            for step in leg.steps {
                                let directionStep: DirectionStep = DirectionStep()
                                if legIndex <= Static.cachedRoutes[Static.modeOfTransportation]!.count{
                                    if Static.cachedRoutes[Static.modeOfTransportation]![legIndex].errandText.isEmpty{
                                        directionStep.errandGroupNumber = "To " + Static.cachedRoutes[Static.modeOfTransportation]![legIndex].title
                                    }else{
                                        directionStep.errandGroupNumber = "To " + Static.cachedRoutes[Static.modeOfTransportation]![legIndex].errandText
                                    }
                                    
                                }
                                directionStep.directionText = step.html_instructions.stringByReplacingOccurrencesOfString("<[^>]+>", withString: " ", options: .RegularExpressionSearch, range: nil);
                                
                                
                                directionStep.stepIndex = instructionIndex;
                                if(instructionIndex != 1)
                                {
                                    directionStep.distance = step.distance.text
                                    directionStep.duration = step.duration.text
                                }
                                
                                directionsList.append(directionStep);
                                instructionIndex++;
                            }
                            
                            Static.cachedDirectionsGrouped[Static.modeOfTransportation]!.append(directionsList)
                            legIndex++
                        }
                        
                        
                        // accomplishing 1 decimal place with * 10 / 10
                        self.totalDistanceMiles = Double(round(Double(self.totalDistanceMeters) * 0.000621371 * 10)/10)
                        // let timeInt: Int = round(self.durationSeconds / 60)
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

                        Static.cachedInfoOverlays[Static.modeOfTransportation] = UITextView()
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.frame = CGRect(x: CGFloat(9), y: (self.buttonRect.frame.minY) - 60, width: CGFloat(boxWidth), height: CGFloat(50))
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.tag = 99
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.editable = false
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.backgroundColor = UIColor.blackColor()
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.alpha = 0.7
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.layer.cornerRadius = 5
                        let font: UIFont = UIFont(name: "AvenirNext-DemiBold", size: 13)!
                        let fontAttr = [NSFontAttributeName:font]
                    
                        let styledString = NSMutableAttributedString()
                        let distTitle: NSMutableAttributedString = NSMutableAttributedString(string:"total distance: ", attributes: fontAttr)
                        distTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#40e0d0"), range: NSRange(location:0, length: distTitle.length))
                        let timeTitle: NSMutableAttributedString = NSMutableAttributedString(string:"total travel time: ", attributes: fontAttr)
                        timeTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#40e0d0"), range: NSRange(location:0, length: timeTitle.length))
                        let totalDistTxt: NSMutableAttributedString = NSMutableAttributedString(string: String(self.totalDistanceMiles) + " miles", attributes: fontAttr)
                        totalDistTxt.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0, length: totalDistTxt.length))
                        let timeTextMutable: NSMutableAttributedString = NSMutableAttributedString(string: timeText)
                        timeTextMutable.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSRange(location: 0, length:timeTextMutable.length))
                        styledString.appendAttributedString(distTitle)
                        styledString.appendAttributedString(totalDistTxt)
                        //line break
                        styledString.appendAttributedString(NSAttributedString(string:"\n"))
                        styledString.appendAttributedString(timeTitle)
                        styledString.appendAttributedString(timeTextMutable)
                        
                        let paraStyle = NSMutableParagraphStyle()
                        paraStyle.lineSpacing = 1.0
                        
                        // Apply paragraph styles to paragraph
                        styledString.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: NSRange(location: 0,length: styledString.length))
                        
                        Static.cachedInfoOverlays[Static.modeOfTransportation]!.attributedText = styledString
                        self.view.addSubview(Static.cachedInfoOverlays[Static.modeOfTransportation]!)
                        
                        
                        for routeLocation in Static.cachedRoutes[Static.modeOfTransportation]! {
                            // Add markers to map:
                            let marker = GoogleMapMarker()
                            marker.position = routeLocation.position
                            marker.placeId = routeLocation.placeId
                            marker.title = routeLocation.title
                            marker.snippet = routeLocation.snippet
                            marker.errandOrder = routeLocation.errandOrder
                            marker.errandText = routeLocation.errandText
                            marker.appearAnimation = kGMSMarkerAnimationPop
                            if routeLocation.isErrand {
                                marker.icon = UIImage(named: "Marker Filled-25")
                            } else {
                                marker.icon = UIImage(named: "Marker-25-coral")
                            }
                            marker.map = self.mapView
                        }
                        
                        // Only interested in routes[0] right now
                        break;
                    }
                } else {
                    Static.mapErroredOut = true
                    self.DisplayErrorAlert("")
                    return
                }
        }
    }
    
    func RejectLocation(placeId: String)
    {
        do {
            
            if placeId == "" {
                // Inform user we have no alternative locations to provide
                // because this is an address duh!
                let title: String = "no alternative locations"
                let msg: String = "unfortunately there are no alternative locations to offer you for this place."
                let noAltsAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                    return
                })
                noAltsAlertController.addAction(okAction)
                self.presentViewController(noAltsAlertController, animated: true, completion: nil)
                return
            }
            
            //TODO: add loading overlay here
         
//            Static.cachedRoutes[Static.modeOfTransportation] = []
//            Static.closestLocationsPerErrand.removeAll()
//            noResults.removeAll()
//            Static.cachedDirectionsGrouped[Static.modeOfTransportation] = [[]]
            
            //Identify rejected location within currentRouteLocations
            //and remove it from currentRouteLocations
            var rejected: Coordinates = Coordinates()
            for var i = 0; i < Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.count; i++ {
                if (Static.cachedCurrentRouteLocations[Static.modeOfTransportation]![i]!.placeId == placeId) {
                    rejected = Static.cachedCurrentRouteLocations[Static.modeOfTransportation]![i]!
                    Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.removeAtIndex(i)
                    break
                }
            }
         
            var hasMoreAlternatives = false
            var hasZeroAlternatives = false
            var closestLocationsPerErrandTemp:[[Coordinates]] = [[]]
            closestLocationsPerErrandTemp.removeAll()
            var locationResultsIdx_ofRejected: Int = 0
            
            for var i = 0; i < Static.locationResults.count; i++ {
                if (Static.locationResults[i].errandTermId == rejected.errandTermId) {
                    Static.locationResults[i].usedPlaceIds.append(placeId)
                    let excludedPlaceIds: [String] = Static.locationResults[i].usedPlaceIds
                    
                    //Get next top locations for rejected errand
                    let closestLocations: [Coordinates] = GetClosestLocationsForErrand(Static.locationResults[i].locationSearchResults!, errandTermId: rejected.errandTermId, errandText: Static.locationResults[i].errandText, excludedPlaceIds: excludedPlaceIds)
                    if (closestLocations.count > 0) {
                        
                        hasMoreAlternatives = true
                        
                        // Add next top closest locations for the rejected errand
                        closestLocationsPerErrandTemp.append(closestLocations)
                        
                    } else {
                        
                        hasMoreAlternatives = false
                        locationResultsIdx_ofRejected = i
                        
                        if (excludedPlaceIds.count > 1) {
                            hasZeroAlternatives = false
                        } else {
                            hasZeroAlternatives = true
                        }
                    }
                    
                } else {
                    //Get top locations for non-rejected 
                    closestLocationsPerErrandTemp.append(GetClosestLocationsForErrand(Static.locationResults[i].locationSearchResults!,
                        errandTermId: Static.locationResults[i].errandTermId, errandText: Static.locationResults[i].errandText, excludedPlaceIds: Static.locationResults[i].usedPlaceIds))
                }
            }
            
            
            if hasMoreAlternatives {
                
                Static.closestLocationsPerErrand.removeAll()
                Static.closestLocationsPerErrand = closestLocationsPerErrandTemp
                RecalcRouteFromRejected()
                
            } else {
                //No more results, so can't provide a new location
                var noresultsAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                if hasZeroAlternatives {
                    
                    //Inform user we have no alternative locations to provide
                    let title2: String = "no more alternative locations"
                    let msg2: String = "unfortunately there are no more alternative locations to offer you for this errand."
                    noresultsAlertController = UIAlertController(title: title2, message: msg2, preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                        return
                    })
                    
                    self.noResults.removeAll()
                    for (index, value) in Static.locationResults[locationResultsIdx_ofRejected].usedPlaceIds.enumerate() {
                        if(value == placeId) {
                            Static.locationResults[locationResultsIdx_ofRejected].usedPlaceIds.removeAtIndex(index)
                        }
                    }
                    Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.append(rejected)
                    
                    noresultsAlertController.addAction(okAction)
                    self.presentViewController(noresultsAlertController, animated: true, completion: nil)
                    return
                    
                } else {
                    
                    let title: String = "no more alternative locations"
                    let msg: String = "would you like to start over at the top of the list?"
                    noresultsAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                        
                        //If yes, clear out UsedPlaceIds for this errand and re-map:
                        Static.locationResults[locationResultsIdx_ofRejected].usedPlaceIds.removeAll()
                        self.noResults.removeAll()
                        Static.closestLocationsPerErrand.removeAll()
                        Static.closestLocationsPerErrand = closestLocationsPerErrandTemp
                        
                        Static.closestLocationsPerErrand.append(self.GetClosestLocationsForErrand(Static.locationResults[locationResultsIdx_ofRejected].locationSearchResults!,
                            errandTermId: Static.locationResults[locationResultsIdx_ofRejected].errandTermId, errandText: Static.locationResults[locationResultsIdx_ofRejected].errandText, excludedPlaceIds: nil))
                        
                        self.RecalcRouteFromRejected()
                    })
                    
                    let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                        //If no, exit method and do nothing:
                        self.noResults.removeAll()
                        
                        for (index, value) in Static.locationResults[locationResultsIdx_ofRejected].usedPlaceIds.enumerate() {
                            if(value == placeId) {
                                Static.locationResults[locationResultsIdx_ofRejected].usedPlaceIds.removeAtIndex(index)
                            }
                        }
                        
                        Static.cachedCurrentRouteLocations[Static.modeOfTransportation]!.append(rejected)
                        return
                    })
                    
                    noresultsAlertController.addAction(yesAction)
                    noresultsAlertController.addAction(noAction)
                    self.presentViewController(noresultsAlertController, animated: true, completion: nil)
                    
                }
                
            }
            
        } catch {
            Static.mapErroredOut = true
            DisplayErrorAlert("")
        }
    }
    
    func RecalcRouteFromRejected() {
        // Clear out variables:
        Static.cachedRoutes[Static.modeOfTransportation] = []
        noResults.removeAll()
        Static.cachedDirectionsGrouped[Static.modeOfTransportation] = [[]]
        
        // Clear all map markers and polylines
        mapView?.clear()
        Static.cachedPaths[Static.modeOfTransportation] = GMSMutablePath()
        
        //Remove route info textview
        if let viewWithTag = self.view.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
            Static.cachedInfoOverlays[Static.modeOfTransportation] = nil
            self.durationSeconds = 0
            self.totalDistanceMeters = 0
        }
        
        // Now map it!
        CreateRoute()
    }
    
    func DisplayErrorAlert(var errorMessage: String)
    {
        if(errorMessage.isEmpty){
            Static.mapErroredOut = true
            errorMessage = "we are sorry. it seems a meteorite hit the app at an unexpected pace. please try landing your spaceship and relaunching."
        }
        
        let alertController = UIAlertController(title: "yikes!", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let tryAgainAction = UIAlertAction(title: "try again", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        alertController.addAction(tryAgainAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    func configureLoadingMessage() {
        var iterations: String = "7"
        var numberOfErrands: Int = 1
        
        if (firstViewController!.destinationToggle as UISwitch).on{
        numberOfErrands = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count - 1
        }
        else{
            numberOfErrands = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count - 2
        }
        
        if numberOfErrands == 2{
            iterations = "256"
        }
        else if numberOfErrands == 3{
            iterations = "13,122"
        }
        else if numberOfErrands == 4{
            iterations = "393,216"
        }
        else if numberOfErrands == 5{
            iterations = "9,375,000"
        }
        
        let message = "testing " + iterations + " route combinations..."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        alert.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: {(alertAction: UIAlertAction!) in
            Static.mapErroredOut = true
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
        alert.addAction(cancelAction)
        alert.view.addSubview(loadingIndicator)
        presentViewController(alert, animated: true, completion: nil)
        loadingAlertIsDisplayed = true
    }
    
    
//    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
//        var infoWindow = NSBundle.mainBundle().loadNibNamed("CustomInfoWindow", owner: self, options: nil).first! as CustomInfoWindow
//        infoWindow.label.text = "\(marker.position.latitude) \(marker.position.longitude)"
//        return infoWindow
//    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if let viewWithTag = self.view.viewWithTag(23) {

            viewWithTag.removeFromSuperview()
        }
        
        selectedMarker = marker as! GoogleMapMarker
        if selectedMarker.placeId == "" {
            return false
        }
        
        let rejectBtn = UIButton()
        rejectBtn.setTitle("reject this location", forState: .Normal)
        rejectBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        rejectBtn.backgroundColor = UIColor(hexString: "#FF6666")
        rejectBtn.layer.cornerRadius = 5
        rejectBtn.layer.borderWidth = 1
        rejectBtn.layer.borderColor = UIColor(hexString: "#FF6666").CGColor
        rejectBtn.frame = CGRectMake(12, mapView!.bounds.minY + 110, 200, 40)
        rejectBtn.tag = 23
        rejectBtn.addTarget(self, action: "onRejectLocation:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(rejectBtn)
        return false
    }
    
    func onRejectLocation(sender: UIButton!) {
        if let viewWithTag = self.view.viewWithTag(23) {
            viewWithTag.removeFromSuperview()
        }
        RejectLocation(selectedMarker.placeId)
    }
    
    func mapView(mapView: GMSMapView!, didCloseInfoWindowOfMarker marker: GMSMarker!) -> Bool {

        if let viewWithTag = self.view.viewWithTag(23) {

            viewWithTag.removeFromSuperview()
        }
        return false
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if let viewWithTag = self.view.viewWithTag(23) {
            viewWithTag.removeFromSuperview()

        }

    }

}
