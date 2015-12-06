//
//  NearEarthObject.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import Foundation

struct NearEarthObject {
    let isHazardous: Bool
    
    init?(json: AnyObject) {      
        guard let jsonDictionary = json as? [String:AnyObject],
        let isHazardous = jsonDictionary["is_potentially_hazardous_asteroid"] as? Bool else {
            return nil
        }
        
        self.isHazardous = isHazardous
    }
}