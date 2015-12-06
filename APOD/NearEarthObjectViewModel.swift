//
//  NearEarthObjectViewModel.swift
//  APOD
//
//  Created by Tom Burns on 12/6/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import RxSwift
import RxCocoa

struct NearEarthObjectViewModel {
    let object: NearEarthObject
    
    let objectName: Driver<String>
    
    init(object: NearEarthObject) {
        self.object = object
        self.objectName = Drive.just(object.name)
    }
}