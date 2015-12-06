//
//  HomeViewController.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var objectCountLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    let searchRange = PublishSubject<HomeViewModel.SearchRange>()
    
    lazy var viewModel: HomeViewModel? = nil
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = HomeViewModel(searchRange: self.searchRange.asDriver(onErrorJustReturn: (NSDate(),NSDate())))
        
        viewModel.refresh()
        
        configureDatePickers()
        
        viewModel.objectCount.driveNext { (count) -> Void in
            self.objectCountLabel.text = count
            }
            .addDisposableTo(disposeBag)
        
        viewModel.searchDescription.driveNext { (description) -> Void in
            self.dateRangeLabel.text = description
            }
            .addDisposableTo(disposeBag)
        
        self.viewModel = viewModel
    }
    
    
    @IBAction func refresh(sender: AnyObject) {
        viewModel?.refresh()
    }
    
    
    private func configureDatePickers() {
        startDatePicker.rx_date.subscribeNext { (date) -> Void in
            defer {
                // always emit fresh search range when start date is set
                self.searchRange.onNext((self.startDatePicker.date,self.endDatePicker.date))
            }
            
            // ensure that end date is within valid window, and adjust picker if not
            let minComponents = NSDateComponents()
            minComponents.day = 1
            
            if let minDate = NSCalendar.currentCalendar().dateByAddingComponents(minComponents, toDate: date, options: []) {
                if self.endDatePicker.date.compare(minDate) == NSComparisonResult.OrderedAscending {
                    self.endDatePicker.date = minDate
                }
                
                self.endDatePicker.minimumDate = minDate
                
            }
            
            // update maximum end date
            let maxComponents = NSDateComponents()
            maxComponents.day = 7
            self.endDatePicker.maximumDate = NSCalendar.currentCalendar().dateByAddingComponents(maxComponents, toDate: date, options: [])
            
            }
            .addDisposableTo(disposeBag)
        
        
        endDatePicker.rx_date.subscribeNext { (date) -> Void in
            defer {
                // always emit fresh search range when end date is set
                self.searchRange.onNext((self.startDatePicker.date,self.endDatePicker.date))
            }
            }
            .addDisposableTo(disposeBag)
    }
}

