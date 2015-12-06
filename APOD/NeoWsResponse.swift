//
//  NeoWsResponse.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import Foundation

struct NeoWsResponse {
    let elementCount: Int
    
    let startDate: NSDate
    let endDate: NSDate
    
    let nearEarthObjects: [String:[NearEarthObject]]
    
    init?(json: AnyObject) {
        guard let jsonDictionary = json as? [String:AnyObject],
        let count = jsonDictionary["element_count"] as? Int,
            let nearEarthObjectJSON = jsonDictionary["near_earth_objects"],
            let nearEarthObjects = NeoWsResponse.parseNearEarthObjects(nearEarthObjectJSON) else {
                return nil
        }
        
        let sortedKeys = nearEarthObjects.keys.sort { (first, second) in
            return first.caseInsensitiveCompare(second) == NSComparisonResult.OrderedAscending }
        
        let dateFormatter = NASA.Constants.dateFormatter
        
        guard let startDateString = sortedKeys.first,
        startDate = dateFormatter.dateFromString(startDateString),
            endDateString = sortedKeys.last,
            endDate = dateFormatter.dateFromString(endDateString) else {
            return nil
        }
        
        self.startDate = startDate
        self.endDate = endDate
        
        self.elementCount = count
        self.nearEarthObjects = nearEarthObjects
    }
    
    private static func parseNearEarthObjects(json: AnyObject) -> [String:[NearEarthObject]]? {
        guard let jsonDictionary = json as? [String:[AnyObject]] else {
            return nil
        }
        
        var parsedObjects: [String:[NearEarthObject]] = [:]
        
        for (key,jsonArray) in jsonDictionary {
            
            parsedObjects[key] = jsonArray.flatMap({ (json) -> NearEarthObject? in
                return NearEarthObject(json: json)
            })
        }
        
        return parsedObjects
    }
}