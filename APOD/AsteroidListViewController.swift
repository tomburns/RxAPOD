//
//  AsteroidListViewController.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class AsteroidListViewController: UIViewController, UITableViewDelegate, AsteroidViewModelConsumer {
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    var viewModel: AsteroidViewModel!
    
    var objectCellViewModels = Variable([NearEarthObjectViewModel]())
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, NearEarthObjectViewModel>>()
    
    typealias Section = SectionModel<String, NearEarthObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.objectCellViewModels
            .driveNext { [unowned self] (newObjects) -> Void in
            self.objectCellViewModels.value = newObjects
            }
            .addDisposableTo(disposeBag)
        
        dataSource.cellFactory = { (tv, ip, object: NearEarthObjectViewModel) in
            let cell = tv.dequeueReusableCellWithIdentifier("NearEarthObjectListCell")!
            
            if let cell = cell as? NearEarthObjectTableViewCell {
                cell.viewModel = object
            }

            return cell
        }
        
        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            return dataSource.sectionAtIndex(sectionIndex).model
        }
        
        // reactive data source
        objectCellViewModels
            .map{ objects in
                return [SectionModel(model: "Near Earth Objects", items: objects)]
            }
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    }

}
