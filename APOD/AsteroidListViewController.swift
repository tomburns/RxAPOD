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

// objc monkey business
public class _RxTableViewSectionedDataSource : NSObject
, UITableViewDataSource {
    
    func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _numberOfSectionsInTableView(tableView)
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (nil as UITableViewCell?)!
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _tableView(tableView, titleForHeaderInSection: section)
    }
    
    func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _tableView(tableView, titleForFooterInSection: section)
    }
}

struct ItemPath : CustomDebugStringConvertible {
    let sectionIndex: Int
    let itemIndex: Int
    
    var debugDescription : String {
        get {
            return "(\(sectionIndex), \(itemIndex))"
        }
    }
}

public struct Changeset<S: SectionModelType> : CustomDebugStringConvertible {
    typealias I = S.Item
    
    var reloadData: Bool = false
    
    var finalSections: [S] = []
    
    var insertedSections: [Int] = []
    var deletedSections: [Int] = []
    var movedSections: [(from: Int, to: Int)] = []
    var updatedSections: [Int] = []
    
    var insertedItems: [ItemPath] = []
    var deletedItems: [ItemPath] = []
    var movedItems: [(from: ItemPath, to: ItemPath)] = []
    var updatedItems: [ItemPath] = []
    
    public static func initialValue(sections: [S]) -> Changeset<S> {
        var initialValue = Changeset<S>()
        initialValue.insertedSections = Array(0 ..< sections.count)
        initialValue.finalSections = sections
        initialValue.reloadData = true
        
        return initialValue
    }
    
    public var debugDescription : String {
        get {
            let serializedSections = "[\n" + finalSections.map { "\($0)" }.joinWithSeparator(",\n") + "\n]\n"
            return " >> Final sections"
                + "   \n\(serializedSections)"
                + (insertedSections.count > 0 || deletedSections.count > 0 || movedSections.count > 0 || updatedSections.count > 0 ? "\nSections:" : "")
                + (insertedSections.count > 0 ? "\ninsertedSections:\n\t\(insertedSections)" : "")
                + (deletedSections.count > 0 ?  "\ndeletedSections:\n\t\(deletedSections)" : "")
                + (movedSections.count > 0 ? "\nmovedSections:\n\t\(movedSections)" : "")
                + (updatedSections.count > 0 ? "\nupdatesSections:\n\t\(updatedSections)" : "")
                + (insertedItems.count > 0 || deletedItems.count > 0 || movedItems.count > 0 || updatedItems.count > 0 ? "\nItems:" : "")
                + (insertedItems.count > 0 ? "\ninsertedItems:\n\t\(insertedItems)" : "")
                + (deletedItems.count > 0 ? "\ndeletedItems:\n\t\(deletedItems)" : "")
                + (movedItems.count > 0 ? "\nmovedItems:\n\t\(movedItems)" : "")
                + (updatedItems.count > 0 ? "\nupdatedItems:\n\t\(updatedItems)" : "")
        }
    }
}

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        fatalError(error)
    #else
        print(error)
    #endif
}

public class RxTableViewSectionedDataSource<S: SectionModelType> : _RxTableViewSectionedDataSource {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (UITableView, NSIndexPath, I) -> UITableViewCell
    
    public typealias IncrementalUpdateObserver = AnyObserver<Changeset<S>>
    
    public typealias IncrementalUpdateDisposeKey = Bag<IncrementalUpdateObserver>.KeyType
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    var sectionModels: [SectionModelSnapshot] = []
    
    public func sectionAtIndex(section: Int) -> S {
        return self.sectionModels[section].model
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self.sectionModels[indexPath.section].items[indexPath.item]
    }
    
    var incrementalUpdateObservers: Bag<IncrementalUpdateObserver> = Bag()
    
    public func setSections(sections: [S]) {
        self.sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var cellFactory: CellFactory! = nil
    
    public var titleForHeaderInSection: ((section: Int) -> String)?
    public var titleForFooterInSection: ((section: Int) -> String)?
    
    public var rowAnimation: UITableViewRowAnimation = .Automatic
    
    public override init() {
        super.init()
        self.cellFactory = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }
            
            return (nil as UITableViewCell!)!
        }
    }
    
    // observers
    
    public func addIncrementalUpdatesObserver(observer: IncrementalUpdateObserver) -> IncrementalUpdateDisposeKey {
        return incrementalUpdateObservers.insert(observer)
    }
    
    public func removeIncrementalUpdatesObserver(key: IncrementalUpdateDisposeKey) {
        let element = incrementalUpdateObservers.removeKey(key)
        precondition(element != nil, "Element removal failed")
    }
    
    // UITableViewDataSource
    
    override func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].items.count
    }
    
    override func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        precondition(indexPath.item < sectionModels[indexPath.section].items.count)
        
        return cellFactory(tableView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(section: section)
    }
    
    override func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(section: section)
    }
    
}

public protocol SectionModelType {
    typealias Item
    
    var items: [Item] { get }
    
    init(original: Self, items: [Item])
}

class RxTableViewSectionedReloadDataSource<S: SectionModelType> : RxTableViewSectionedDataSource<S>
, RxTableViewDataSourceType {
    typealias Element = [S]
    
    func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let element):
            setSections(element)
            tableView.reloadData()
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}

public struct SectionModel<Section, ItemType> : SectionModelType, CustomStringConvertible {
    public typealias Item = ItemType
    public var model: Section
    
    public var items: [Item]
    
    public init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
    
    public init(original: SectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
    public var description: String {
        get {
            return "\(self.model) > \(items)"
        }
    }
}


class AsteroidListViewController: UIViewController, UITableViewDelegate, AsteroidViewModelConsumer {
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    
    var viewModel: AsteroidViewModel! = nil
    
    var objects = Variable([NearEarthObject]())
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, NearEarthObject>>()
    
    typealias Section = SectionModel<String, NearEarthObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.objects
            .debug("objects")
            .driveNext { (newObjects) -> Void in
            self.objects.value = newObjects
            }
            .addDisposableTo(disposeBag)
        
        dataSource.cellFactory = { (tv, ip, object: NearEarthObject) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell")!
            //                cell.textLabel?.text = object.firstName + " " + object.lastName
            return cell
        }
        
        dataSource.titleForHeaderInSection = { [unowned dataSource] sectionIndex in
            return dataSource.sectionAtIndex(sectionIndex).model
        }
        
        // reactive data source
        objects
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
