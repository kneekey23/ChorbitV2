//
//  MainViewController.swift
//  ChorbitV2
//
//  Created by Nicki on 11/29/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

//any shared variables between the three scenes(user profile, featured routes, and the search) go in this controller NJK
class MainViewController: UITabBarController, GMSMapViewDelegate{
    //if this variable is here we can control it from any screen. thinking of featured routes, you click on one we populate this variable and pass it on through NJK
    internal var errandSelection: Array<Errand> = []
    internal var prevErrandSelection: Array<String> = []
    internal var prevModeOfTransportation : String = "driving"
    internal var _cachedErrandLocations : [GoogleMapMarker] = []
    internal var cachedPolylinePath = GMSMutablePath()
    internal var cachedBounds : GMSCoordinateBounds?
    internal var directionsGrouped: [[DirectionStep]] = [[]]
    internal var closestLocationsPerErrand:[[Coordinates]] = [[]]
    internal var currentRouteLocations: [Coordinates?] = []
    internal var cachedLocationResults: [ErrandResults] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


