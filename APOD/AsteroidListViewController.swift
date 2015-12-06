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
    
    var viewModel: AsteroidViewModel! = nil
    
    var objectCellViewModels = Variable([NearEarthObjectViewModel]())
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, NearEarthObjectViewModel>>()
    
    typealias Section = SectionModel<String, NearEarthObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.objectCellViewModels
            .debug("objects")
            .driveNext { (newObjects) -> Void in
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
            .debug()
            .map{ objects in
                return [SectionModel(model: "Near Earth Objects", items: objects)]
            }
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        // customization using delegate
        // RxTableViewDelegateBridge will forward correct messages
        tableView.rx_setDelegate(self)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: Table view delegate ;)
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource.sectionAtIndex(section)
        
        let label = UILabel(frame: CGRect.zero)
        // hacky I know :)
        label.text = "  \(title)"
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.darkGrayColor()
        label.alpha = 0.9
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
