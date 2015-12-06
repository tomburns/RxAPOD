//
//  NearEarthObjectTableViewCell.swift
//  APOD
//
//  Created by Tom Burns on 12/6/15.
//  Copyright © 2015 Claptrap, LLC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class NearEarthObjectTableViewCell: UITableViewCell {
    
    private var disposeBag: DisposeBag?
    
    var viewModel: NearEarthObjectViewModel? {
        didSet {
            let disposeBag = DisposeBag()
            
            if let labelObservable = self.textLabel?.rx_text {
                viewModel?.objectName.drive(labelObservable)
                .addDisposableTo(disposeBag)
            }
            
            
//            (viewModel?.title ?? Drive.just(""))
//                .drive(self.titleOutlet.rx_text)
//                .addDisposableTo(disposeBag)
//            
//            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString ?? ""
//            
//            viewModel.imageURLs
//                .drive(self.imagesOutlet.rx_itemsWithCellIdentifier("ImageCell")) { [unowned self] (_, URL, cell: CollectionViewImageCell) in
//                    cell.downloadableImage = self.imageService.imageFromURL(URL)
//                }
//                .addDisposableTo(disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = nil
    }
}
