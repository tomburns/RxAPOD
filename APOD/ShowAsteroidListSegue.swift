//
//  ShowAsteroidListSegue.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import UIKit

class ShowAsteroidListSegue: UIStoryboardSegue {
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        
        listViewController.viewModel = homeViewController.viewModel
    }
    
    private var homeViewController: AsteroidViewModelConsumer {
        return sourceViewController as! AsteroidViewController
    }
    
    private var listViewController: AsteroidListViewController {
        return destinationViewController as! AsteroidListViewController
    }
}
