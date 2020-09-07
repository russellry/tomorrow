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
    func updateEntries() {
        refresh()
        debugPrint(fetchedRC.fetchedObjects)
    }

    @IBOutlet weak var calendarView: FSCalendar!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Entry>!
    weak var updateEntriesDelegate: EntryChangeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateEntriesDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        debugPrint(fetchedRC.fetchedObjects)
    }
}

extension ProfileViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("select: ")
        //TODO: for MM-dd-YYYY -> obtain from core data
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
