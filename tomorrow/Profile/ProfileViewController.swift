//
//  ProfileViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 30/8/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData
import StoreKit

protocol EntryChangeDelegate: class {
    func updateEntries()
}

protocol ReloadProfileTableDelegate: class {
    func setupTodayDate()
}

class ProfileViewController: UIViewController, EntryChangeDelegate, ReloadProfileTableDelegate {
    
    let productCellId = "ImmutableEntryTableViewCell"
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Entry>!
    weak var updateEntriesDelegate: EntryChangeDelegate?
    weak var reloadProfileTableDelegate: ReloadProfileTableDelegate?
    var yearlyProduct: SKProduct?
    var monthlyProduct: SKProduct?
    let format = DateFormatter()
    var groupedDateStrings: [Entry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEntriesDelegate = self
        reloadProfileTableDelegate = self
        setupNib()
        setupTimezone()
        refresh()
        setupTodayDate()
        setupPremium()
    }
    
    fileprivate func setupPremium(){
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        if !isPremium {
            fetchProducts()
        }
    }
    
    func updateEntries() {
        refresh()
    }
    
    fileprivate func setupTimezone(){
        format.timeZone = .current
        format.dateFormat = "yyyy-MM-dd"
    }
    
    fileprivate func setupNib(){
        let nib = UINib(nibName: productCellId, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: productCellId)
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func setupTodayDate(){
        groupedDateStrings = []
        for entry in fetchedRC.fetchedObjects! {
            let str1 = format.string(from: entry.dateCreated)
            let dateSelected = UserDefaults.standard.object(forKey: "dateSelected") as! Date

            let str2 = format.string(from: dateSelected)

            if str1 == str2 {
                groupedDateStrings.append(entry)
            }
        }
        tableView.reloadData()
    }
}

extension ProfileViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        
        if isPremium {
            groupedDateStrings = []
            UserDefaults.standard.set(date, forKey: "dateSelected")
            for entry in fetchedRC.fetchedObjects! {
                let str1 = format.string(from: entry.dateCreated)
                let str2 = format.string(from: date)
                if str1 == str2 {
                    groupedDateStrings.append(entry)
                }
            }
            tableView.reloadData()
        } else {
            performSegue(withIdentifier: "toPremium", sender: nil)
        }
    }
}

extension ProfileViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        yearlyProduct = response.products.last
        monthlyProduct = response.products.first
    }
    
    fileprivate func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: ["tomorrow.monthly.subscription", "tomorrow.yearly.subscription.discount"])
        request.delegate = self
        request.start()
    }
}

extension ProfileViewController: CellDynamicHeightProtocol {
    func updateHeightOfRow(_ cell: EntryTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        if size.height.rounded(.down) != newSize.height.rounded(.down) {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}

//MARK: - Fetching from CoreData
extension ProfileViewController: NSFetchedResultsControllerDelegate {
    private func refresh() {
        let request = Entry.fetchRequest() as NSFetchRequest<Entry>
        let sort = NSSortDescriptor(key: #keyPath(Entry.dateCreated), ascending: true)
        request.sortDescriptors = [sort]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedRC.delegate = self
            try fetchedRC.performFetch()
        } catch let error as NSError {
            NSLog("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedDateStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: productCellId, for: indexPath) as! ImmutableEntryTableViewCell
        cell.selectionStyle = .none
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: groupedDateStrings[indexPath.row].task)

        if groupedDateStrings[indexPath.row].done {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        cell.labelView.attributedText = attributeString
        cell.sizeToFit()
        
        return cell
    }
    
    
}
