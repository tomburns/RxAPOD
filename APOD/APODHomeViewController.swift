//
//  APODHomeViewController.swift
//  APOD
//
//  Created by Tom Burns on 12/6/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class APODHomeViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var retryView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    
    private let date = PublishSubject<NSDate>()
    
    var viewModel: APODViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        viewModel = APODViewModel(date: date.asDriver(onErrorJustReturn: NSDate()))
        
        configureRetryView()
        
        datePicker.rx_date.subscribeNext { [unowned self] (newDate) -> Void in
            self.date.onNext(newDate)
            }
            .addDisposableTo(disposeBag)
        
        retryButton.rx_tap.subscribeNext { [unowned self] in
            self.date.onNext(self.datePicker.date)
        }
        .addDisposableTo(disposeBag)
    }
    
    func configureRetryView() {
        retryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(retryView)
        
//        retryView.hidden = true
        retryView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor, constant: 0).active = true
        retryView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: 0).active = true
    }
}