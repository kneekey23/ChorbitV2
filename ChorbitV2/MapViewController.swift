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

class MapViewController: UIViewController{
    
 weak var firstViewController : SearchViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.cameraWithLatitude(-33.868,
            longitude:151.2086, zoom:6)
        let mapView = GMSMapView.mapWithFrame(CGRectMake(0, 60, 375, 600), camera:camera)
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "Marker Filled-25")
        marker.map = mapView
        
        self.view.addSubview(mapView)
    }
    

}
