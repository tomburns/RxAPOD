//
//  APODResponse.swift
//  APOD
//
//  Created by Tom Burns on 12/6/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import Foundation

struct APODResponse {
    
    let URL: NSURL
    let mediaType: MediaType
    
    let title: String
    let explanation: String
    
    init?(json: AnyObject) {
        guard let jsonDictionary = json as? [String:AnyObject],
            let URLString = jsonDictionary["url"] as? String,
            let URL = NSURL(string: URLString),
            let mediaTypeString = jsonDictionary["media_type"] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let title = jsonDictionary["title"] as? String,
            let explanation = jsonDictionary["explanation"] as? String else {
                return nil
        }
        
        self.title = title
        self.explanation = explanation
        
        self.URL = URL
        self.mediaType = mediaType
    }
    
    enum MediaType: String {
        case Image = "image"
    }
}



//
//{
//    "url": "http://apod.nasa.gov/apod/image/1512/casimirsphere_mohideen_960.jpg",
//    "media_type": "image",
//    "explanation": "This tiny ball provides evidence that the universe will expand forever.  Measuring slightly over one tenth of a millimeter, the ball moves toward a smooth plate in response to energy fluctuations in the vacuum of empty space.  The attraction is known as the Casimir Effect, named for its discoverer, who, 55 years ago, was trying to understand why fluids like mayonnaise move so slowly.  Today, evidence indicates that most of the energy density in the universe is in an unknown form dubbed dark energy.  The form and genesis of dark energy is almost completely unknown, but postulated as related to vacuum fluctuations similar to the Casimir Effect but generated somehow by space itself.  This vast and mysterious dark energy appears to gravitationally repel all matter and hence will likely cause the universe to expand forever.  Understanding vacuum energy is on the forefront of research not only to better understand our universe but also for stopping micro-mechanical machine parts from sticking together.",
//    "concepts": [],
//    "title": "A Force from Empty Space: The Casimir Effect"
//}