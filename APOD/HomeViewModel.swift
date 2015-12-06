//
//  HomeViewModel.swift
//  APOD
//
//  Created by Tom Burns on 12/5/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import RxSwift
import RxCocoa

struct HomeViewModel {
    
    typealias SearchRange = (start: NSDate, end: NSDate)
    
    private struct Constants {
        static let loadingText = "Loading…"
        static let errorText = "<Error>"
    }
    
    let objectCount: Driver<String>
    private let _objectCount = BehaviorSubject<String>(value: Constants.loadingText)
    
    let searchRange: Driver<SearchRange>
    
    let searchDescription: Driver<String>
    private let _searchDescription = BehaviorSubject<String>(value: Constants.loadingText)
    
    init(searchRange: Driver<SearchRange>) {
        self.objectCount = _objectCount.asDriver(onErrorJustReturn: Constants.errorText)
        self.searchDescription = _searchDescription.asDriver(onErrorJustReturn: Constants.errorText)
        self.searchRange = searchRange
        
        searchRange
            .filter { (start, end) -> Bool in
                return start.compare(end) == NSComparisonResult.OrderedAscending
            }
            .driveNext { (start, end) -> Void in
                self.refresh(startDate: start, endDate: end)
            }
            .addDisposableTo(disposeBag)
    }
    
    private let disposeBag = DisposeBag()
    
    func refresh(startDate startDate: NSDate? = nil, endDate: NSDate? = nil) {
        
        setLoadingState()
        
        self.neoWsObservable(startDate: startDate, endDate: endDate)
            .subscribe(onNext: { (response) -> Void in
                self._objectCount.onNext("\(response.elementCount)")
                
                let dateFormatter = NASA.Constants.dateFormatter
                let startDateString = dateFormatter.stringFromDate(response.startDate)
                let endDateString = dateFormatter.stringFromDate(response.endDate)
                
                self._searchDescription.onNext("\(startDateString) - \(endDateString)")
                
                },
                onError: { (error) -> Void in
                    print(error)
                    self.setErrorState()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func neoWsObservable(startDate startDate: NSDate? = nil, endDate: NSDate? = nil) -> Observable<NeoWsResponse> {
        return NASADefaultProvider.request(NASA.NeoWs(startDate: startDate, endDate: endDate))
            .filterSuccessfulStatusCodes()
            .retry(3)
            .mapJSON()
            .map { json -> NeoWsResponse in
                if let response = NeoWsResponse(json: json) {
                    return response
                } else {
                    throw NASAError.JSON
                }
        }
    }
    
    private func setLoadingState() {
        self._objectCount.onNext(Constants.loadingText)
        self._searchDescription.onNext(Constants.loadingText)
    }
    
    private func setErrorState() {
        self._objectCount.onNext(Constants.errorText)
        self._searchDescription.onNext(Constants.errorText)
    }
    
}