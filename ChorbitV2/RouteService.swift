//
//  RouteService.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 11/8/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation

class RouteService {
    
    private var elementLevel = -1;
    private var numberOfElements: Int = 0;
    private var permutationValue = [Int]();
    var permutations = [[Int]]();
    
    func getOptimizedRoute (origin: Coordinates, errands: [[Coordinates]], destination: Coordinates) -> [Coordinates] {
        
        let errandA: ErrandDistance = ErrandDistance();
        let errandB: ErrandDistance = ErrandDistance();
        let errandC: ErrandDistance = ErrandDistance();
        var bestRoute: [Coordinates];
        var bestRouteSequence: [Int];
        var bestRouteCombo: [Coordinates];
        var bestRoute_errandA: Coordinates = Coordinates();
        var bestRoute_errandB: Coordinates = Coordinates();
        var bestRoute_errandC: Coordinates = Coordinates();
        
        if (errands.count >= 1) {
            errandA.locations = errands[0];
        }
        if (errands.count >= 2) {
            errandB.locations = errands[1];
        }
        if (errands.count >= 3) {
            errandC.locations = errands[2];
        }
        
        var routeTest: RouteTest  = RouteTest();
        var param: String  = "";
        
        let allErrandLocations: [Coordinates] = errands.flatMap {$0};
        
        
        
        
        return bestRoute;
    }
}