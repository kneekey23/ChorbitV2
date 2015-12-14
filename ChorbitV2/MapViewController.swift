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
import GooglePlaces

class MapViewController: UIViewController{
    
    let firstViewController: SearchViewController = SearchViewController()
    var origin: Coordinates?
    var destination: Coordinates?
    var noResults: [String] = []
    var locationResults: [ErrandResults] = []
    var numErrands: Int = 0
    var closestLocationsPerErrand:[Coordinates] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.cameraWithLatitude(-33.868,
            longitude:151.2086, zoom:6)
        let mapView = GMSMapView.mapWithFrame(UIScreen.mainScreen().bounds, camera:camera)
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "Marker Filled-25")
        marker.map = mapView
        
        self.view.addSubview(mapView)
    }
    
    func GetLocationInformation() {
        var latlng:String?
        var lat: Double = 0
        var lng: Double = 0
        var subtitle:String? = ""
        let segmentedControl = (firstViewController.startingLocationControl)! as UISegmentedControl
        
         if segmentedControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex) == "Use New Location"{
            //geocode location address to find coords and set them here with subtitle NJK
        }
         else{
            lat = firstViewController.myGeoLocatedCoords.coordinate.latitude
            lng = firstViewController.myGeoLocatedCoords.coordinate.longitude
            subtitle = (firstViewController.addressString)
            
        }
        latlng = String(format: "%02d,%02d", lat, lng)
        origin = Coordinates(lat: lat, long: lng, title: "My starting location", subtitle: subtitle!, errandTermId: -1, placeId: "", errandText: "", errandOrder: nil)
        
        if(firstViewController.destinationToggle as UISwitch).on{
            destination = origin
        }
        else{
            //geocode last item in errand selection arrayto find the coordinates
        }
        
        
        
        
    }
    
    func GetClosestLocationsForErrand(latlng: String, errand: String, excludedPlaceIds: [String]){
      
        var gp = GooglePlaces()
        gp.search(location, radius: 100, query: errand) { (items, errorDescription) -> Void in
            
            println("Result count: \(items!.count)")
            if items.count > 0{
                var maxResults: Int = 7
                if(items.count < maxResults){
                    maxResults = items!.count
                }
            }
            
            var filteredResults: [Result] = items.categorize {$0.Vicinity }
            
            for result in filteredResults {
                if maxResults < 1 {
                    break
                }
                if(excludedPlaceIds != nil){
                    var isExcluded: Bool = false
                    for id in excludedPlaceIds{
                        if id == result.place_id{
                            isExcluded = true
                            continue
                        }
                    }
                    if(isExcluded){
                        continue
                    }
                }
                
                println([items![index].name])
            }
        }
        
        
    }
    

}
