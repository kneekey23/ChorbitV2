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
    var mapErroredOut: Bool = false
//    var directionsGrouped: [[DirectionStep]] = [[]]
    var temp: [DirectionStep] = []
    var selectedMarker: GoogleMapMarker = GoogleMapMarker()
    var errandAddress: Coordinates?
    var modeOfTransportation: String = "driving"
    var recalc = false
    
    var placeResponsesAwaiting: Int = 0;
    var allPlaceRequestsSent: Bool = false;
    
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
        static var _errandLocations: [GoogleMapMarker] = []
        static var path = GMSMutablePath()
        static var closestLocationsPerErrand:[[Coordinates]] = [[]]
        static var currentRouteLocations: [Coordinates?] = []
        static var locationResults: [ErrandResults] = []
        static var _isRoundTrip: Bool = true
        static var infoOverlay: UITextView!
    }
    
    @IBOutlet weak var transportationTyoe: UISegmentedControl!
    @IBOutlet weak var buttonRect: UIButton!
    @IBAction func refreshTrafficConditions(sender: AnyObject) {
        //refresh route goes here NJK
        mapView?.clear()
        if let viewWithTag = self.view.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
            Static.infoOverlay = nil
             self.durationSeconds = 0
             self.totalDistanceMeters = 0
        }
//        self.directionsGrouped.removeAll()
        (firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped.removeAll()
        Static._errandLocations.removeAll()
        Static.currentRouteLocations.removeAll()
        self.CreateRoute()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Caching
        let totalNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).errandSelection.count
        let prevNumberOfErrands: Int = (firstViewController?.parentViewController?.parentViewController as! MainViewController).prevErrandSelection.count
        
        if totalNumberOfErrands != prevNumberOfErrands || prevNumberOfErrands == 0 {
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
        
        // End caching
        
        let myLocation: CLLocation = (firstViewController!.myGeoLocatedCoords) as CLLocation!
        let camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom:6)

        mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera:camera)
        mapView!.delegate = self
      
        self.view.addSubview(mapView!)
        self.view.addSubview(buttonRect)
        self.view.addSubview(transportationTyoe)
        
        if !recalc {
            for routeLocation in Static._errandLocations {
                // Add cached markers to map:
                let marker = GoogleMapMarker()
                marker.position = routeLocation.position
                marker.placeId = routeLocation.placeId
                marker.title = routeLocation.title
                marker.snippet = routeLocation.snippet
                marker.errandOrder = routeLocation.errandOrder
                marker.errandText = routeLocation.errandText
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.icon = UIImage(named: "Marker Filled-25")
                marker.map = self.mapView
            }
            
            let polyline = GMSPolyline(path: Static.path)
            polyline.map = self.mapView
            
            let padding = CGFloat(30)
            let bounds = (firstViewController?.parentViewController?.parentViewController as! MainViewController).cachedBounds
            let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
            self.mapView!.animateWithCameraUpdate(fitBounds)
            self.mapView?.addSubview(Static.infoOverlay)
            //removes loading view from screen NJK
            self.dismissViewControllerAnimated(false, completion: nil)
        } else {
            Static.path = GMSMutablePath()
            (firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped.removeAll()
            Static._errandLocations.removeAll()
            Static.currentRouteLocations.removeAll()
            
            configureLoadingMessage()
            GetLocationInformation()
        }
    }
    
    @IBAction func changeTransportationType(sender: AnyObject) {
        //code to change from driving to walking to transit goes here.NJK
        let segmentedControl: UISegmentedControl = sender as! UISegmentedControl
        
        if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "drive"{
            //default is here. possibly do nothing? NJK
            modeOfTransportation = "driving"
            
        }
        else if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "walk"{
            //code for walking goes here. NJK
            modeOfTransportation = "walking"
            
        }
        else{
            //transit goes here NJK
            modeOfTransportation = "cycling"
        }
        mapView?.clear()
        if let viewWithTag = self.view.viewWithTag(99) {
            viewWithTag.removeFromSuperview()
            Static.infoOverlay = nil
            self.durationSeconds = 0
            self.totalDistanceMeters = 0
        }
        
        (firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped.removeAll()
        Static._errandLocations.removeAll()
        Static.currentRouteLocations.removeAll()
        self.CreateRoute()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToDirectionsSegue"{
            let directionsViewController = segue.destinationViewController as! DirectionsController
            directionsViewController.directions = temp
//            directionsViewController.directionsGrouped = self.directionsGrouped
            directionsViewController.directionsGrouped = (firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped
            
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
          Static.origin = Coordinates(lat: lat, long: lng, title: "my starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil)
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
                         Static.origin = Coordinates(lat: lat, long: lng, title: "my starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil)
                        
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
                                let closestLocations: [Coordinates] = self.GetClosestLocationsForErrand(l!, errandTermId: errandTermId , errandText: errand.errandString, excludedPlaceIds: nil )
                                
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
                                self.mapErroredOut = true
                                self.DisplayErrorAlert(locationsNotFound)
                                return
                            }
                            
                            if(self.allPlaceRequestsSent && self.placeResponsesAwaiting == 0){
                                
                                self.CreateRoute()
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
                        
                       
                    }
                
            }
            //do nothing becayse it's an address that has been entered as an errand NJK
            dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(nil, nil, count: count)
                
                
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
        Static.currentRouteLocations = []
        var locations: [Coordinates?] = []
        locations.append(Static.origin)

            //Only hit up algorithm for optimized route if there are 2 or more errands
            if (Static.closestLocationsPerErrand.count > 1) {
                let routeServiceUrl = "https://b97482pu3h.execute-api.us-west-2.amazonaws.com/test/ChorbitAlgorithm"
                
                let routeServiceRequest: RouteServiceRequest = RouteServiceRequest(origin: Static.origin!, errands: Static.closestLocationsPerErrand, destination: Static.destination!, mode: modeOfTransportation)
                
                let requestObj: AnyObject = routeServiceRequest
                let JSONString = Mapper().toJSONString(routeServiceRequest)
                let params: [String: AnyObject] = ["request": JSONString!]
                
                Alamofire.request(.POST, routeServiceUrl, parameters: params, encoding: .JSON)
                    .responseJSON { response in
                        
                        if let json = response.result.value {
                            let routeServiceResponse: RouteServiceResponse = RouteServiceResponse(json as! [String : AnyObject])
                            
                            for r in routeServiceResponse.results {
                                //print(r)
                                Static.currentRouteLocations.append(Coordinates?(r))
                            }
                            
                            if(Static.currentRouteLocations.count < 1) {
                                self.dismissViewControllerAnimated(false, completion: nil)
                                let errandsNotFound: String = "unable to find locations for your errands. please go back and try again."
                                self.DisplayErrorAlert(errandsNotFound)
                                self.mapErroredOut = true;
                                return;
                            }
                            
                            locations += Static.currentRouteLocations;
                            
                           self.MapResults(locations)
                        }
                }
                
                
                
            } else {
                //This just means that there's only one errand
                for locationList in Static.closestLocationsPerErrand {
                    if(locationList.count > 0) {
                        locations.append(locationList[0]);
                        Static.currentRouteLocations = locations;
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
            
            Static._errandLocations.append(GoogleMapMarker(coordinate: CLLocationCoordinate2DMake(value!.lat, value!.long), title: locationTitle, snippet: value!.subtitle, placeId: value!.placeId, errandText: value!.errandText, errandOrder: index))
        }
        
        var noresultsAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
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
                self.mapErroredOut = true;
                noresultsAlertController.addAction(tryAgainAction)
            }
            
        }
        
        if (Static._isRoundTrip && Static._errandLocations.count > 0) {
            Static._errandLocations.append(Static._errandLocations[0])
        }
        
        //            let waypoints = _errandLocations[2..._errandLocations.count - 1]
        
        if(self.modeOfTransportation == "cycling"){
            self.modeOfTransportation = "bicycling"
        }
        
        let destIdx = Static._errandLocations.count - 1;
        
        var url = "https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyC6M9LV04OJ2mofUcX69tHaz5Aebdh8enY&origin=\(Static._errandLocations[0].position.latitude),\(Static._errandLocations[0].position.longitude)&destination=\(Static._errandLocations[destIdx].position.latitude),\(Static._errandLocations[destIdx].position.longitude)&mode=\(self.modeOfTransportation)&waypoints="
        
        for var i = 1; i < Static._errandLocations.count - 1; i++ {
            url += "\(Static._errandLocations[i].position.latitude),\(Static._errandLocations[i].position.longitude)"
            if(i != Static._errandLocations.count - 1) {
                url += "|"
            }
        }
        
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        

            self.GetDirections(url);

        
        if (Static._errandLocations.count == 0) {
            self.dismissViewControllerAnimated(false, completion: nil)
            let locationsNotFound: String = "unable to find locations for your errands. please go back and try again."
            self.DisplayErrorAlert(locationsNotFound)
            self.mapErroredOut = true
            return
        }
        
        //Present Alert
        if (self.noResults.count > 0) {
            self.dismissViewControllerAnimated(false, completion: nil)
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
//                        if (route.overview_polyline != nil) {
                            polylinePts = route.overview_polyline.points
//                        }
                        
                        if (!polylinePts.isEmpty) {
                            let polylineCoords: [CLLocationCoordinate2D]? = decodePolyline(polylinePts)
                            
                            for polylineCoord in polylineCoords! {
                                Static.path.addCoordinate(polylineCoord)
                            }
                            
                            let polyline = GMSPolyline(path: Static.path)
                            polyline.map = self.mapView
                        }
                        
                        // Bounds contains the viewport bounding box of the overview_polyline
                        let southwest = CLLocationCoordinate2DMake(route.bounds.southwest.lat, route.bounds.southwest.lng)
                        let northeast = CLLocationCoordinate2DMake(route.bounds.northeast.lat, route.bounds.northeast.lng)
                        let bounds = GMSCoordinateBounds(coordinate: southwest, coordinate: northeast)
                        (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).cachedBounds = bounds
                        
                        let padding = CGFloat(30)
                        let fitBounds = GMSCameraUpdate.fitBounds(bounds, withPadding: padding)
                        self.mapView!.animateWithCameraUpdate(fitBounds)
                        //removes loading view from screen NJK
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                    
                        var legIndex: Int = 1;
                        for leg in route.legs {

                            self.totalDistanceMeters += leg.distance.value

                            self.durationSeconds += leg.duration.value

                            var instructionIndex: Int = 1;
                         
                            var directionsList: [DirectionStep] = []
                            
                            for step in leg.steps {
                                let directionStep: DirectionStep = DirectionStep()
                                if legIndex <= Static._errandLocations.count{
                                    if Static._errandLocations[legIndex].errandText.isEmpty{
                                        directionStep.errandGroupNumber = "To " + (Static.destination?.subtitle)!
                                    }else{
                                        directionStep.errandGroupNumber = "To " + Static._errandLocations[legIndex].errandText
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
                            //                            self.directionsGrouped.append(directionsList)
                            (self.firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped.append(directionsList)
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

                        Static.infoOverlay = UITextView()
                        Static.infoOverlay.frame = CGRect(x: CGFloat(9), y: (self.buttonRect.frame.minY) - 60, width: CGFloat(boxWidth), height: CGFloat(50))
                        Static.infoOverlay.tag = 99
                        Static.infoOverlay.editable = false
                        Static.infoOverlay.backgroundColor = UIColor.blackColor()
                        Static.infoOverlay.alpha = 0.7
                        Static.infoOverlay.layer.cornerRadius = 5
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
                        
                        Static.infoOverlay.attributedText = styledString
                        self.view.addSubview(Static.infoOverlay)
                        
                        
                        for routeLocation in Static._errandLocations {
                            // Add markers to map:
                            let marker = GoogleMapMarker()  //GMSMarker()
                            marker.position = routeLocation.position
                            marker.placeId = routeLocation.placeId
                            marker.title = routeLocation.title
                            marker.snippet = routeLocation.snippet
                            marker.errandOrder = routeLocation.errandOrder
                            marker.errandText = routeLocation.errandText
                            marker.appearAnimation = kGMSMarkerAnimationPop
                            marker.icon = UIImage(named: "Marker Filled-25")
                            marker.map = self.mapView
                        }
                        
                        // Only interested in routes[0] right now
                        break;
                    }
                }
                
                
        }
    }
    
    func RejectLocation(placeId: String)
    {
        do {
            //TODO: add loading overlay here
         
            Static._errandLocations.removeAll()
            Static.closestLocationsPerErrand.removeAll()
            noResults.removeAll()
//            directionsGrouped.removeAll()
            (firstViewController?.parentViewController?.parentViewController as! MainViewController).directionsGrouped.removeAll()
            
            //Identify rejected location within currentRouteLocations
            //and remove it from currentRouteLocations
            var rejected: Coordinates = Coordinates()
            for var i = 0; i < Static.currentRouteLocations.count; i++ {
                if (Static.currentRouteLocations[i]!.placeId == placeId) {
                    rejected = Static.currentRouteLocations[i]!
                    Static.currentRouteLocations.removeAtIndex(i)
                    break
                }
            }
            
         
            for var i = 0; i < Static.locationResults.count; i++ {
                if (Static.locationResults[i].errandTermId == rejected.errandTermId) {
                    //Add the next 3 locations for the rejected errand
                    Static.locationResults[i].usedPlaceIds.append(placeId)
                    let excludedPlaceIds: [String] = Static.locationResults[i].usedPlaceIds
                    
                    //Get next top locations for rejected errand
                    let closestLocations: [Coordinates] = GetClosestLocationsForErrand(Static.locationResults[i].locationSearchResults!, errandTermId: rejected.errandTermId, errandText: Static.locationResults[i].errandText, excludedPlaceIds: excludedPlaceIds)
                    if (closestLocations.count > 0) {
                        Static.closestLocationsPerErrand.append(closestLocations)
                    } else {
                        //No more results, so can't provide a new location
                        
                        
                        var noresultsAlertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                      
                        if (excludedPlaceIds.count > 0) {
                            let title: String = "no more alternative locations"
                            let msg: String = "would you like to start over at the top of the list?"
                            noresultsAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                                //If yes, clear out UsedPlaceIds for this errand and re-map:
                                Static.locationResults[i].usedPlaceIds.removeAll()
                                self.noResults.removeAll()
                               Static.closestLocationsPerErrand.append(self.GetClosestLocationsForErrand(Static.locationResults[i].locationSearchResults!,
                                    errandTermId: Static.locationResults[i].errandTermId, errandText: Static.locationResults[i].errandText, excludedPlaceIds: nil))
                            })
                            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                                //If no, exit method and do nothing:
                                self.noResults.removeAll()
                                
                                for (index, value) in Static.locationResults[i].usedPlaceIds.enumerate() {
                                    if(value == placeId) {
                                        Static.locationResults[i].usedPlaceIds.removeAtIndex(index)
                                    }
                                }
                                
                                Static.currentRouteLocations.append(rejected)
                                // _loadPop.hide()
                                return
                            })
                            
                            noresultsAlertController.addAction(yesAction)
                            noresultsAlertController.addAction(noAction)
                        } else {
                            //Inform user we have no alternative locations to provide
                            let title2: String = "no more alternative locations"
                            let msg2: String = "unfortunately there are no more alternative locations to offer you for this errand."
                            noresultsAlertController = UIAlertController(title: title2, message: msg2, preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {(alertAction: UIAlertAction!) in
                                self.noResults.removeAll()
                                for (index, value) in Static.locationResults[i].usedPlaceIds.enumerate() {
                                    if(value == placeId) {
                                        Static.locationResults[i].usedPlaceIds.removeAtIndex(index)
                                    }
                                }
                                Static.currentRouteLocations.append(rejected)
                                // _loadPop.hide()
                                return
                            })
                            
                            noresultsAlertController.addAction(okAction)
                        }
                    }
                    
                } else {
                    //Get top locations for non-rejected 
                    Static.closestLocationsPerErrand.append(GetClosestLocationsForErrand(Static.locationResults[i].locationSearchResults!,
                        errandTermId: Static.locationResults[i].errandTermId, errandText: Static.locationResults[i].errandText, excludedPlaceIds: Static.locationResults[i].usedPlaceIds))
                }
            }
            
            //Remove route info textview
            if let viewWithTag = self.view.viewWithTag(99) {
                viewWithTag.removeFromSuperview()
                Static.infoOverlay = nil
                self.durationSeconds = 0
                self.totalDistanceMeters = 0
            }
            
            // Clear all map markers and polylines
            mapView?.clear()
            
            CreateRoute()
            
            // Clear out old polylines from cached variable:
            Static.path = GMSMutablePath()
            
        } catch {
            DisplayErrorAlert("")
        }
    }
    
    func DisplayErrorAlert(var errorMessage: String)
    {
        if(errorMessage.isEmpty){
            mapErroredOut = true
            errorMessage = "we are sorry. it seems a meteorite hit the app at an unexpected pace. please try landing your spaceship and relaunching."
        }
        
        let alertController = UIAlertController(title: "error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
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
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        
        alert.addAction(cancelAction)
        alert.view.addSubview(loadingIndicator)
        presentViewController(alert, animated: true, completion: nil)
        
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
           // print("found view with tag 23")
            viewWithTag.removeFromSuperview()

        }

    }

}
