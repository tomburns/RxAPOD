//
//  NASA.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import Moya
import RxSwift

let NASADefaultProvider: RxMoyaProvider<NASA> = {
    let provider = RxMoyaProvider<NASA>(plugins: [/*NetworkLoggerPlugin()*/])

    return provider
}()

enum NASA {
    struct Constants {
        // Replace this with your own key, obtained at
        // https://api.nasa.gov/index.html#apply-for-an-api-key
        static let APIKey = "DLmU2KznRNhHOiiX82Nmb9MUjwwbNh5PxaigXJiA"
        
        static let baseURLString = "https://api.nasa.gov"
        
        static let dateFormatter: NSDateFormatter = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
    }
    
    case APOD(NSDate)
    case NeoWs(startDate: NSDate?, endDate: NSDate?)
}


extension NASA: TargetType {
    var baseURL: NSURL { return NSURL(string: Constants.baseURLString)! }
    
    var path: String {
        switch self {
        case .APOD:
            return "/planetary/apod"
        case .NeoWs:
            return "/neo/rest/v1/feed"
        }
    }
    
    var method: Moya.Method {
        return .GET
    }
    
    var parameters: [String: AnyObject]? {
        var parameters = [ "api_key" : Constants.APIKey,
            "format" : "JSON" ]
        
        switch self {
        case .APOD(let date):
            
            parameters["date"] = NASA.Constants.dateFormatter.stringFromDate(date)
        case .NeoWs(let start, let end):
            let startDate = start ?? NSDate()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            parameters["start_date"] = dateFormatter.stringFromDate(startDate)
            
            if let endDate = end {
                parameters["end_date"] = dateFormatter.stringFromDate(endDate)
            }
            
            
        }
        
        return parameters
    }
    
    var sampleData: NSData {
        switch self {
        case .APOD:
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        case .NeoWs:
            return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

enum NASAError: ErrorType {
    case JSON
}
