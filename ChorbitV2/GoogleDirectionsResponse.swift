//
//  GoogleDirectionsResponse.swift
//  ChorbitV2
//
//  Created by Melissa Hargis on 12/21/15.
//  Copyright © 2015 shortkey. All rights reserved.
//

import Foundation


class GoogleDirectionsResponse {
    
    /**
     * geocoder_status: "OK"
     * place_id: "ChIJjSir2uF_24ARedFIM-SQ2bs"
     * types: ["street_address"]
     */
    let geocoded_waypoints: [Geocoded_waypoints]
    
    /**
     * bounds: {"northeast":{"lat":33.50029620000001,"lng":-117.0768901},"southwest":{"lat":33.080905,"lng":-117.2054379}}
     * copyrights: "Map data ©2015 Google"
     * legs: []
     * overview_polyline: {"points":"}gjkElrdjUqb@~Dm]nEoHpEmEbEpAsEWsCyByA{Bf@sEpKoAtAaCp@oEiAmBqFz@cGjDwJ|A_[?yZqDiv@yDyNaDuFwAeCh@q@dAmA`H_GVq@tVsTfHcEvM{Dbz@gTrx@wSnOiDxLeAhWN``AwEhMAnOrBvf@~K|QlGdR|JjPjMnLdMvUhYdMpJpQzKp|@xk@`ZhSp]bXhVjOjHpD|UvIpMvCfNjDbIrBk@nEoLdF_BfBk@bCHxC~ApGEvBcDbFHjGy@rD_@dE~CnOz@tFpB`EzF~O`CxHNbCh@tCnBrA~CjA`ChDlBvFrE|Kr@|E@xF\\dBZX`@U`AeA`BhD|AJ}@Ew@[cBsCiAzAq@_BIsE_@qFcHmReCwEiCuAkDgB}@gGkFmQuFaM_FeWSiCzAeGJ_J|BiC`@qBuBoL^cCpAoBdJaEfBy@j@{A?{AfFeCnC}@hEcAxCs@~U{F~L}EjMwHzNgMzXmYdRgMvIwDpOmE~MqB|No@|lClAzc@[lP}BhRyFdR{J~RwKnHkD`QkFbWiD|Ys@dx@gB`Qa@~UA|LlAxNfDzz@f`@tMfFzRfE`PpAhP@xTeBhUsGbf@sOrQ_Gb}@yYbmAy`@dU}JzUsN`p@oc@jn@a`@`bB_x@zrBuaArYkM~KuC|NiBnc@DrsBdEvODnNaAlNmCdRsGxP}Hpv@c_@nq@s\\zLeHzMcKtLsJrEeDnDINCb@Fx@uDxB?nO~BdAUP}AdBsP~AmNfA}BhIsGnUbDjGdAt@kHu@jHkGeAySgDg@?]JsIlHw@zBmE~a@eAToO_CkB[R_B`@oDXeCLgAM{Ae@R}A|CqElHuB|CuJdKiInHwPtLcRpJa`@rRgu@t\\w]hRkMbE_RvCuOj@cgAqBekAyByNR_RhC{MtD_TrJ}`A~d@{oAlm@iz@|`@mg@`Yi]dUoZlSmd@nXcSlI{XdJ_[`K_s@`U_jAj_@{[`KyVtCyW@_TgCaPuEyZkNm]kP_SmGmRgCsOK{b@~@kgAnCmQdByGpA}NhE_j@rYkN|FyGdBiRpCcYVmjCkAiPDcMx@kWjFyMlFqWpQaUdVaL`KeNtIwJdEuSnFeH|@{Qp@wMUuNoAoU_HaQcIuMyHyg@_`@{h@a^{bAoo@yKgJsTyXoO_PuRaNkMaGgLwDe`@{IeS_E{Oq@{i@pCsTjAyTMeOf@oa@zIkMdD}CZsPhBWIb@iCnUck@jAsEb@qIoBuTIcJ|@qX]iHmGu`@gVeyAg\\spBuAsIg@MiOxGaBl@q@XqAmCgCiGK["}
     * summary: "I-15 S"
     * warnings: []
     * waypoint_order: [0,1]
     */
    let routes: [Routes]
    
    /** status: "OK" */
    let status: String
    
    init (_ json: [String: AnyObject]) {
        
        if let geocoded_waypoints = json["geocoded_waypoints"] as? [[String: AnyObject]] {
            var result = [Geocoded_waypoints]()
            for obj in geocoded_waypoints {
                result.append(Geocoded_waypoints(obj))
            }
            self.geocoded_waypoints = result
        } else {
            self.geocoded_waypoints = [Geocoded_waypoints]()
        }
        
        if let routes = json["routes"] as? [[String: AnyObject]] {
            var result = [Routes]()
            for obj in routes {
                result.append(Routes(obj))
            }
            self.routes = result
        } else {
            self.routes = [Routes]()
        }
        
        if let status = json["status"] as? String { self.status = status }
        else { self.status = "" }
    }
}

class Routes {
    
    /**
     * northeast: {"lat":33.50029620000001,"lng":-117.0768901}
     * southwest: {"lat":33.080905,"lng":-117.2054379}
     */
    let bounds: Bounds
    
    /** copyrights: "Map data ©2015 Google" */
    let copyrights: String
    
    /**
     * distance: {"text":"13.9 mi","value":22410}
     * duration: {"text":"18 mins","value":1088}
     * end_address: "365-499 White Fox Run, Fallbrook, CA 92028, USA"
     * end_location: {"lat":33.3813791,"lng":-117.2054699}
     * start_address: "27810 Vía Santa Rosa, Temecula, CA 92590, USA"
     * start_location: {"lat":33.481111,"lng":-117.1743145}
     * steps: []
     * via_waypoint: []
     */
    let legs: [Legs]
    
    /**
     * points: "}gjkElrdjUqb@~Dm]nEoHpEmEbEpAsEWsCyByA{Bf@sEpKoAtAaCp@oEiAmBqFz@cGjDwJ|A_[?yZqDiv@yDyNaDuFwAeCh@q@dAmA`H_GVq@tVsTfHcEvM{Dbz@gTrx@wSnOiDxLeAhWN``AwEhMAnOrBvf@~K|QlGdR|JjPjMnLdMvUhYdMpJpQzKp|@xk@`ZhSp]bXhVjOjHpD|UvIpMvCfNjDbIrBk@nEoLdF_BfBk@bCHxC~ApGEvBcDbFHjGy@rD_@dE~CnOz@tFpB`EzF~O`CxHNbCh@tCnBrA~CjA`ChDlBvFrE|Kr@|E@xF\\dBZX`@U`AeA`BhD|AJ}@Ew@[cBsCiAzAq@_BIsE_@qFcHmReCwEiCuAkDgB}@gGkFmQuFaM_FeWSiCzAeGJ_J|BiC`@qBuBoL^cCpAoBdJaEfBy@j@{A?{AfFeCnC}@hEcAxCs@~U{F~L}EjMwHzNgMzXmYdRgMvIwDpOmE~MqB|No@|lClAzc@[lP}BhRyFdR{J~RwKnHkD`QkFbWiD|Ys@dx@gB`Qa@~UA|LlAxNfDzz@f`@tMfFzRfE`PpAhP@xTeBhUsGbf@sOrQ_Gb}@yYbmAy`@dU}JzUsN`p@oc@jn@a`@`bB_x@zrBuaArYkM~KuC|NiBnc@DrsBdEvODnNaAlNmCdRsGxP}Hpv@c_@nq@s\\zLeHzMcKtLsJrEeDnDINCb@Fx@uDxB?nO~BdAUP}AdBsP~AmNfA}BhIsGnUbDjGdAt@kHu@jHkGeAySgDg@?]JsIlHw@zBmE~a@eAToO_CkB[R_B`@oDXeCLgAM{Ae@R}A|CqElHuB|CuJdKiInHwPtLcRpJa`@rRgu@t\\w]hRkMbE_RvCuOj@cgAqBekAyByNR_RhC{MtD_TrJ}`A~d@{oAlm@iz@|`@mg@`Yi]dUoZlSmd@nXcSlI{XdJ_[`K_s@`U_jAj_@{[`KyVtCyW@_TgCaPuEyZkNm]kP_SmGmRgCsOK{b@~@kgAnCmQdByGpA}NhE_j@rYkN|FyGdBiRpCcYVmjCkAiPDcMx@kWjFyMlFqWpQaUdVaL`KeNtIwJdEuSnFeH|@{Qp@wMUuNoAoU_HaQcIuMyHyg@_`@{h@a^{bAoo@yKgJsTyXoO_PuRaNkMaGgLwDe`@{IeS_E{Oq@{i@pCsTjAyTMeOf@oa@zIkMdD}CZsPhBWIb@iCnUck@jAsEb@qIoBuTIcJ|@qX]iHmGu`@gVeyAg\\spBuAsIg@MiOxGaBl@q@XqAmCgCiGK["
     */
    let overview_polyline: Overview_polyline
    
    /** summary: "I-15 S" */
    let summary: String
    
    /** warnings: [] */
//    let warnings: [AnyObject]
    
    /** waypoint_order: [
     * 	  0,
     * 	  1,
     * 	  ...
     * 	]
     */
    let waypoint_order: [Int]
    
    init (_ json: [String: AnyObject]) {
        
        if let bounds = json["bounds"] as? [String: AnyObject] { self.bounds = Bounds(bounds) }
        else { self.bounds = Bounds([ : ]) }
        
        if let copyrights = json["copyrights"] as? String { self.copyrights = copyrights }
        else { self.copyrights = "" }
        
        if let legs = json["legs"] as? [[String: AnyObject]] {
            var result = [Legs]()
            for obj in legs {
                result.append(Legs(obj))
            }
            self.legs = result
        } else {
            self.legs = [Legs]()
        }
        
        if let overview_polyline = json["overview_polyline"] as? [String: AnyObject] { self.overview_polyline = Overview_polyline(overview_polyline) }
        else { self.overview_polyline = Overview_polyline([ : ]) }
        
        if let summary = json["summary"] as? String { self.summary = summary }
        else { self.summary = "" }
        
        if let waypoint_order = json["waypoint_order"] as? [Int] { self.waypoint_order = waypoint_order }
        else { self.waypoint_order = [Int]() }
    }
}

class Overview_polyline {
    
    /** points: "}gjkElrdjUqb@~Dm]nEoHpEmEbEpAsEWsCyByA{Bf@sEpKoAtAaCp@oEiAmBqFz@cGjDwJ|A_[?yZqDiv@yDyNaDuFwAeCh@q@dAmA`H_GVq@tVsTfHcEvM{Dbz@gTrx@wSnOiDxLeAhWN``AwEhMAnOrBvf@~K|QlGdR|JjPjMnLdMvUhYdMpJpQzKp|@xk@`ZhSp]bXhVjOjHpD|UvIpMvCfNjDbIrBk@nEoLdF_BfBk@bCHxC~ApGEvBcDbFHjGy@rD_@dE~CnOz@tFpB`EzF~O`CxHNbCh@tCnBrA~CjA`ChDlBvFrE|Kr@|E@xF\\dBZX`@U`AeA`BhD|AJ}@Ew@[cBsCiAzAq@_BIsE_@qFcHmReCwEiCuAkDgB}@gGkFmQuFaM_FeWSiCzAeGJ_J|BiC`@qBuBoL^cCpAoBdJaEfBy@j@{A?{AfFeCnC}@hEcAxCs@~U{F~L}EjMwHzNgMzXmYdRgMvIwDpOmE~MqB|No@|lClAzc@[lP}BhRyFdR{J~RwKnHkD`QkFbWiD|Ys@dx@gB`Qa@~UA|LlAxNfDzz@f`@tMfFzRfE`PpAhP@xTeBhUsGbf@sOrQ_Gb}@yYbmAy`@dU}JzUsN`p@oc@jn@a`@`bB_x@zrBuaArYkM~KuC|NiBnc@DrsBdEvODnNaAlNmCdRsGxP}Hpv@c_@nq@s\\zLeHzMcKtLsJrEeDnDINCb@Fx@uDxB?nO~BdAUP}AdBsP~AmNfA}BhIsGnUbDjGdAt@kHu@jHkGeAySgDg@?]JsIlHw@zBmE~a@eAToO_CkB[R_B`@oDXeCLgAM{Ae@R}A|CqElHuB|CuJdKiInHwPtLcRpJa`@rRgu@t\\w]hRkMbE_RvCuOj@cgAqBekAyByNR_RhC{MtD_TrJ}`A~d@{oAlm@iz@|`@mg@`Yi]dUoZlSmd@nXcSlI{XdJ_[`K_s@`U_jAj_@{[`KyVtCyW@_TgCaPuEyZkNm]kP_SmGmRgCsOK{b@~@kgAnCmQdByGpA}NhE_j@rYkN|FyGdBiRpCcYVmjCkAiPDcMx@kWjFyMlFqWpQaUdVaL`KeNtIwJdEuSnFeH|@{Qp@wMUuNoAoU_HaQcIuMyHyg@_`@{h@a^{bAoo@yKgJsTyXoO_PuRaNkMaGgLwDe`@{IeS_E{Oq@{i@pCsTjAyTMeOf@oa@zIkMdD}CZsPhBWIb@iCnUck@jAsEb@qIoBuTIcJ|@qX]iHmGu`@gVeyAg\\spBuAsIg@MiOxGaBl@q@XqAmCgCiGK[" */
    let points: String
    
    init (_ json: [String: AnyObject]) {
        
        if let points = json["points"] as? String { self.points = points }
        else { self.points = "" }
    }
}

class Legs {
    
    /**
     * text: "13.9 mi"
     * value: 22410
     */
    let distance: Distance
    
    /**
     * text: "18 mins"
     * value: 1088
     */
    let duration: Duration
    
    /** end_address: "365-499 White Fox Run, Fallbrook, CA 92028, USA" */
    let end_address: String
    
    /**
     * lat: 33.3813791
     * lng: -117.2054699
     */
    let end_location: End_location
    
    /** start_address: "27810 Vía Santa Rosa, Temecula, CA 92590, USA" */
    let start_address: String
    
    /**
     * lat: 33.481111
     * lng: -117.1743145
     */
    let start_location: Start_location
    
    /**
     * distance: {"text":"1.0 mi","value":1550}
     * duration: {"text":"1 min","value":81}
     * end_location: {"lat":33.494351,"lng":-117.1782745}
     * html_instructions: "Head <b>north</b> on <b>Vía Santa Rosa</b> toward <b>Rancho Mesa Rd</b>"
     * polyline: {"points":"}gjkElrdjUaBNaBNwFn@oEb@iBPoCTqCVyAJiGn@uEj@wCZwBTi@Ha@HiATgAVSF_@R{@h@qAv@k@\\UNUNUTg@f@]^_@`@aAjAMJGBI@ECICOI"}
     * start_location: {"lat":33.481111,"lng":-117.1743145}
     * travel_mode: "DRIVING"
     */
    let steps: [Steps]
    
    /** via_waypoint: [] */
//    let via_waypoint: [AnyObject]
    
    init (_ json: [String: AnyObject]) {
        
        if let distance = json["distance"] as? [String: AnyObject] { self.distance = Distance(distance) }
        else { self.distance = Distance([ : ]) }
        
        if let duration = json["duration"] as? [String: AnyObject] { self.duration = Duration(duration) }
        else { self.duration = Duration([ : ]) }
        
        if let end_address = json["end_address"] as? String { self.end_address = end_address }
        else { self.end_address = "" }
        
        if let end_location = json["end_location"] as? [String: AnyObject] { self.end_location = End_location(end_location) }
        else { self.end_location = End_location([ : ]) }
        
        if let start_address = json["start_address"] as? String { self.start_address = start_address }
        else { self.start_address = "" }
        
        if let start_location = json["start_location"] as? [String: AnyObject] { self.start_location = Start_location(start_location) }
        else { self.start_location = Start_location([ : ]) }
        
        if let steps = json["steps"] as? [[String: AnyObject]] {
            var result = [Steps]()
            for obj in steps {
                result.append(Steps(obj))
            }
            self.steps = result
        } else {
            self.steps = [Steps]()
        }
        
    }
}

class Steps {
    
    /**
     * text: "1.0 mi"
     * value: 1550
     */
    let distance: Distance
    
    /**
     * text: "1 min"
     * value: 81
     */
    let duration: Duration
    
    /**
     * lat: 33.494351
     * lng: -117.1782745
     */
    let end_location: End_location
    
    /** html_instructions: "Head <b>north</b> on <b>Vía Santa Rosa</b> toward <b>Rancho Mesa Rd</b>" */
    let html_instructions: String
    
    /**
     * points: "}gjkElrdjUaBNaBNwFn@oEb@iBPoCTqCVyAJiGn@uEj@wCZwBTi@Ha@HiATgAVSF_@R{@h@qAv@k@\\UNUNUTg@f@]^_@`@aAjAMJGBI@ECICOI"
     */
    let polyline: Polyline
    
    /**
     * lat: 33.481111
     * lng: -117.1743145
     */
    let start_location: Start_location
    
    /** travel_mode: "DRIVING" */
    let travel_mode: String
    
    init (_ json: [String: AnyObject]) {
        
        if let distance = json["distance"] as? [String: AnyObject] { self.distance = Distance(distance) }
        else { self.distance = Distance([ : ]) }
        
        if let duration = json["duration"] as? [String: AnyObject] { self.duration = Duration(duration) }
        else { self.duration = Duration([ : ]) }
        
        if let end_location = json["end_location"] as? [String: AnyObject] { self.end_location = End_location(end_location) }
        else { self.end_location = End_location([ : ]) }
        
        if let html_instructions = json["html_instructions"] as? String { self.html_instructions = html_instructions }
        else { self.html_instructions = "" }
        
        if let polyline = json["polyline"] as? [String: AnyObject] { self.polyline = Polyline(polyline) }
        else { self.polyline = Polyline([ : ]) }
        
        if let start_location = json["start_location"] as? [String: AnyObject] { self.start_location = Start_location(start_location) }
        else { self.start_location = Start_location([ : ]) }
        
        if let travel_mode = json["travel_mode"] as? String { self.travel_mode = travel_mode }
        else { self.travel_mode = "" }
    }
}

class Start_location {
    
    /** lat: 33.481111 */
    let lat: Double
    
    /** lng: -117.1743145 */
    let lng: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let lng = json["lng"] as? Double { self.lng = lng }
        else { self.lng = 0 }
    }
}

class Polyline {
    
    /** points: "}gjkElrdjUaBNaBNwFn@oEb@iBPoCTqCVyAJiGn@uEj@wCZwBTi@Ha@HiATgAVSF_@R{@h@qAv@k@\\UNUNUTg@f@]^_@`@aAjAMJGBI@ECICOI" */
    let points: String
    
    init (_ json: [String: AnyObject]) {
        
        if let points = json["points"] as? String { self.points = points }
        else { self.points = "" }
    }
}

class End_location {
    
    /** lat: 33.494351 */
    let lat: Double
    
    /** lng: -117.1782745 */
    let lng: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let lng = json["lng"] as? Double { self.lng = lng }
        else { self.lng = 0 }
    }
}

class Duration {
    
    /** text: "1 min" */
    let text: String
    
    /** value: 81 */
    let value: Int
    
    init (_ json: [String: AnyObject]) {
        
        if let text = json["text"] as? String { self.text = text }
        else { self.text = "" }
        
        if let value = json["value"] as? Int { self.value = value }
        else { self.value = 0 }
    }
}

class Distance {
    
    /** text: "1.0 mi" */
    let text: String
    
    /** value: 1550 */
    let value: Int
    
    init (_ json: [String: AnyObject]) {
        
        if let text = json["text"] as? String { self.text = text }
        else { self.text = "" }
        
        if let value = json["value"] as? Int { self.value = value }
        else { self.value = 0 }
    }
}

class Bounds {
    
    /**
     * lat: 33.50029620000001
     * lng: -117.0768901
     */
    let northeast: Northeast
    
    /**
     * lat: 33.080905
     * lng: -117.2054379
     */
    let southwest: Southwest
    
    init (_ json: [String: AnyObject]) {
        
        if let northeast = json["northeast"] as? [String: AnyObject] { self.northeast = Northeast(northeast) }
        else { self.northeast = Northeast([ : ]) }
        
        if let southwest = json["southwest"] as? [String: AnyObject] { self.southwest = Southwest(southwest) }
        else { self.southwest = Southwest([ : ]) }
    }
}

class Southwest {
    
    /** lat: 33.080905 */
    let lat: Double
    
    /** lng: -117.2054379 */
    let lng: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let lng = json["lng"] as? Double { self.lng = lng }
        else { self.lng = 0 }
    }
}

class Northeast {
    
    /** lat: 33.50029620000001 */
    let lat: Double
    
    /** lng: -117.0768901 */
    let lng: Double
    
    init (_ json: [String: AnyObject]) {
        
        if let lat = json["lat"] as? Double { self.lat = lat }
        else { self.lat = 0 }
        
        if let lng = json["lng"] as? Double { self.lng = lng }
        else { self.lng = 0 }
    }
}

class Geocoded_waypoints {
    
    /** geocoder_status: "OK" */
    let geocoder_status: String
    
    /** place_id: "ChIJjSir2uF_24ARedFIM-SQ2bs" */
    let place_id: String
    
    /** types: [
     * 	  "street_address",
     * 	  ...
     * 	]
     */
    let types: [String]
    
    init (_ json: [String: AnyObject]) {
        
        if let geocoder_status = json["geocoder_status"] as? String { self.geocoder_status = geocoder_status }
        else { self.geocoder_status = "" }
        
        if let place_id = json["place_id"] as? String { self.place_id = place_id }
        else { self.place_id = "" }
        
        if let types = json["types"] as? [String] { self.types = types }
        else { self.types = [String]() }
    }
}

