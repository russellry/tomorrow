//
//  HomeViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 17/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var isEditingText = false
    
    let productCellId = "EntryTableViewCell"
    
    var doneBtn = UIBarButtonItem()
    var addBtn = UIBarButtonItem()
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Entry>!
    
    fileprivate func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func teardownNotificationCenter(){
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        tableView.addGestureRecognizer(tap)
        doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickedDone))
        addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAdd))
        navItem.setRightBarButton(addBtn, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        setupNib()
        setupNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        teardownNotificationCenter()
        super.viewWillDisappear(animated)
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        let location = tap.location(in: self.tableView)
        let path = self.tableView.indexPathForRow(at: location)
        
        if let indexPathForRow = path {
            tableView.selectRow(at: indexPathForRow, animated: false, scrollPosition: .bottom)
        } else {
            let lastRow = tableView.numberOfRows(inSection: 0) - 1
            if lastRow >= 0 {
                let lastCell = tableView.cellForRow(at: IndexPath(row: lastRow, section: 0)) as! EntryTableViewCell
                if !lastCell.textView.text.isEmpty{
                    addEntry(name: "")
                    if let count = fetchedRC.fetchedObjects?.count {
                        let index = IndexPath(row: count - 1, section: 0)
                        let cell = tableView.cellForRow(at: index) as! EntryTableViewCell
                        selectNextPossibleCellTableTap(cell)
                    }
                }
            } else {
                addEntry(name: "")
                if let count = fetchedRC.fetchedObjects?.count {
                    let index = IndexPath(row: count - 1, section: 0)
                    let cell = tableView.cellForRow(at: index) as! EntryTableViewCell
                    selectNextPossibleCellTableTap(cell)
                }
            }
            
        }
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.tableView.contentInset = contentInset
            self.tableView.scrollIndicatorInsets = contentInset
        }
    }
    
    fileprivate func setupNib(){
        let nib = UINib(nibName: productCellId, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: productCellId)
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
    }
    
    @objc func clickedDone() {
        toggleBarButton()
    }
    
    @objc func clickedAdd() {
        toggleBarButton()
        
    }
    
    func toggleBarButton(){
        NSLog(tableView.contentSize.debugDescription) //this is for the whole table
        NSLog(tableView.visibleSize.debugDescription) //this is for the table on the screen
        //        isEditingText = !isEditingText
        //
        //        if isEditingText {
        //            navItem.rightBarButtonItem = doneBtn
        //        } else {
        //            navItem.rightBarButtonItem = addBtn
        //        }
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else { return }
        switch type {
        case .insert:
            tableView.insertRows(at: [cellIndex], with: .fade)
        case .delete:
            tableView.deleteRows(at: [cellIndex], with: .fade)
        default:
            break
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let entries = fetchedRC.fetchedObjects else { return 0 }
        return entries.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = fetchedRC.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: productCellId, for: indexPath) as! EntryTableViewCell
        cell.rowHeightDelegate = self
        cell.selectedCellDelegate = self
        cell.selectNextPossibleCellDelegate = self
        cell.deleteEmptyCellDataDelegate = self
        cell.selectionStyle = .none
        cell.textView.text = entry.value(forKey: "task") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = fetchedRC.object(at: indexPath)
            context.delete(entry)
            appDelegate.saveContext()
            refresh()
        }
    }
}

extension HomeViewController: DeleteEmptyCellDataProtocol {
    func deleteEmptyCellData(_ cell: EntryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: indexPath)
            if entry.task.isEmpty {
                context.delete(entry)
                appDelegate.saveContext()
                refresh()
            }
        }
    }
}

extension HomeViewController: SaveSelectedCellProtocol {
    func saveSelectedCell(_ cell: EntryTableViewCell, text: String){
        if let index = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: index)
            entry.task = text
        }
    }
}

extension HomeViewController: CellDynamicHeightProtocol {
    func updateHeightOfRow(_ cell: EntryTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                    height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let thisIndexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: true)
            }
        }
    }
}

extension HomeViewController: SelectNextCellProtocol {
    func selectNextPossibleCell(_ cell: EntryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            guard let entriesCount = fetchedRC.fetchedObjects?.count else {return}
            if entriesCount - 1 < indexPath.row + 1 {
                addEntry(name: "")
            }
            
            let index = IndexPath(row: indexPath.row + 1, section: 0)
            
            tableView.selectRow(at: index, animated: false, scrollPosition: .bottom)
            let nextCell = tableView.cellForRow(at: index) as! EntryTableViewCell
            nextCell.textView.becomeFirstResponder()
        }
    }
    
    func selectNextPossibleCellTableTap(_ cell: EntryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let index = IndexPath(row: indexPath.row, section: 0)
            tableView.selectRow(at: index, animated: false, scrollPosition: .bottom)
            let nextCell = tableView.cellForRow(at: index) as! EntryTableViewCell
            nextCell.textView.becomeFirstResponder()
        }
    }
}

extension HomeViewController {
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
    
    func addEntry(name: String) {
        let entry = Entry(entity: Entry.entity() , insertInto: context)
        
        entry.task = name
        entry.dateCreated = NSDate() as Date
        entry.done = false
        refresh()
        appDelegate.saveContext()
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
        tableView.endUpdates()
    }
}

