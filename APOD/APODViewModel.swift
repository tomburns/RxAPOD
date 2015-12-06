//
//  APODViewModel.swift
//  APOD
//
//  Created by Tom Burns on 12/6/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

struct APODViewModel {
    let title: Driver<String>
    private let _title = PublishSubject<String>()
        
    let explanation: Driver<String>
    private let _explanation = PublishSubject<String>()

    private let disposeBag = DisposeBag()
    
    init(date: Driver<NSDate>) {
        self.title = _title.asDriver(onErrorJustReturn: "")
        self.explanation = _explanation.asDriver(onErrorJustReturn: "")
        
        date.driveNext { date -> Void in
                self.refresh(date)
            }
            .addDisposableTo(disposeBag)
    }
    
    func refresh(date: NSDate = NSDate()) {
        
        setLoadingState()
        
        self.APODObservable(date: date)
            .subscribe(onNext: { (response) -> Void in
                self._title.onNext(response.title)
                self._explanation.onNext(response.explanation)

                },
                onError: { (error) -> Void in
                    print(error)
                    self.setErrorState()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func APODObservable(date date: NSDate = NSDate()) -> Observable<APODResponse> {
        return NASADefaultProvider.request(NASA.APOD(date))
            .filterSuccessfulStatusCodes()
            .retry(10)
            .mapJSON()
            .map { json -> APODResponse in
                if let response = APODResponse(json: json) {
                    return response
                } else {
                    throw NASAError.JSON
                }
        }
    }
    
    private func setLoadingState() {
    }
    
    private func setErrorState() {
        
    }
}