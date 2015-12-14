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
        
        self.view.addSubview(mapView)
    }
    
   
}
