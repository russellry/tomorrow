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
    
    var entries: [NSManagedObject] = []
    
    var isEditingText = false
    
    let productCellId = "EntryTableViewCell"
    
    var doneBtn = UIBarButtonItem()
    var addBtn = UIBarButtonItem()
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var fetchedRC: NSFetchedResultsController<Entry>!
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = Entry.fetchRequest() as NSFetchRequest<Entry>
        let sort = NSSortDescriptor(key: #keyPath(Entry.dateCreated), ascending: true)
        request.sortDescriptors = [sort]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
            fetchedRC.delegate = self
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        setupNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        
        tableView.addGestureRecognizer(tap)
        
        doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickedDone))
        addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAdd))
        
        navItem.setRightBarButton(addBtn, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        let location = tap.location(in: self.tableView)
        let path = self.tableView.indexPathForRow(at: location)
        if let indexPathForRow = path {
            tableView.selectRow(at: indexPathForRow, animated: true, scrollPosition: .top)
        } else {
            save(name: "")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            tableView.reloadData()
        }
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        isEditingText = !isEditingText
        
        if isEditingText {
            navItem.rightBarButtonItem = doneBtn
        } else {
            navItem.rightBarButtonItem = addBtn
        }
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let index = indexPath ?? (newIndexPath ?? nil)
        guard let cellIndex = index else { return }
        switch type {
        case .insert:
            tableView.insertRows(at: [cellIndex], with: .fade)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = fetchedRC.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: productCellId, for: indexPath) as! EntryTableViewCell
        cell.rowHeightDelegate = self
        cell.selectedCellDelegate = self
        cell.selectionStyle = .none
        cell.textView.text = entry.value(forKey: "task") as? String
        return cell
    }
    
}

extension HomeViewController: SaveSelectedCellProtocol {
    func saveSelectedCell(_ cell: EntryTableViewCell, text: String){
        if let thisIndexPath = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: thisIndexPath)
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

extension HomeViewController {
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Entry",
                                       in: managedContext)!
        
        let entry = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        // 3
        entry.setValue(name, forKeyPath: "task")
        entry.setValue(NSDate(), forKey: "dateCreated")
        entry.setValue(false, forKey: "done")
        
        appDelegate.saveContext()
        // 4
        do {
            try managedContext.save()
            entries.append(entry)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
