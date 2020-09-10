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

protocol EntryChangeDelegate: class {
    func updateEntries()
}

class ProfileViewController: UIViewController, EntryChangeDelegate {
    
    let productCellId = "ImmutableEntryTableViewCell"
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Entry>!
    weak var updateEntriesDelegate: EntryChangeDelegate?
    
    let format = DateFormatter()
    var groupedDateStrings: [Entry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEntriesDelegate = self
        setupNib()
        setupTimezone()
        refresh()
        setupTodayDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
    
    fileprivate func setupTodayDate(){
        for entry in fetchedRC.fetchedObjects! {
            let str1 = format.string(from: entry.dateCreated)
            let str2 = format.string(from: Date())

            if str1 == str2 {
                groupedDateStrings.append(entry)
            }
        }
        tableView.reloadData()
    }
}

extension ProfileViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        groupedDateStrings = []
        for entry in fetchedRC.fetchedObjects! {
            let str1 = format.string(from: entry.dateCreated)
            let str2 = format.string(from: date)
            if str1 == str2 {
                groupedDateStrings.append(entry)
            }
        }
        tableView.reloadData()
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
        cell.labelView.text = groupedDateStrings[indexPath.row].task
        cell.sizeToFit()
        print(cell.frame.height)
        
        return cell
    }
    
    
}
