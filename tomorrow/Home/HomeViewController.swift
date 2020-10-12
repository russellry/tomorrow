//
//  HomeViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 17/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import CoreData
import SideMenu
import Floaty
import StoreKit

class HomeViewController: UIViewController, MenuControllerDelegate {
    
    var isEditingText = false
    
    let productCellId = "EntryTableViewCell"
    let format = DateFormatter()
    var dayComponentFrom = DateComponents()
    var dayComponentTo = DateComponents()
    var startOfDayComponent = DateComponents()
    
    var doneBtn = UIBarButtonItem()
    var addBtn = UIBarButtonItem()
    
    let dimmingView = UIView()
    @IBOutlet weak var floatyQuad: Floaty!
    
    @IBOutlet weak var navbar: UINavigationItem!
    private var sideMenu: SideMenuNavigationController?
    private let settingsVC = SETTINGSVC as! SettingsViewController
    private let profileVC = PROFILEVC as! ProfileViewController
    @IBOutlet weak var tableView: UITableView!
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Entry>!
    let calendar = Calendar.current
    
    var yearlyProduct: SKProduct?
    var monthlyProduct: SKProduct?

    override func viewDidLoad() {
        super.viewDidLoad()
        clearEmptyData()
        setupTimezone()
        tableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        layoutFABforQuadAnimation(floaty: floatyQuad)
        setupPremium()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPremium" {
            if let navigationController = segue.destination as? UINavigationController,
               let presentVC = navigationController.viewControllers.first as? PremiumViewController {
                guard let yearlyProduct = self.yearlyProduct else {return}
                guard let monthlyProduct = self.monthlyProduct else {return}
                
                presentVC.monthlyLabelText = monthlyProduct.localizedPrice
                presentVC.yearlyLabelText = yearlyProduct.localizedPrice + "*"
                presentVC.monthlyDiscountLabelText = "*Save 25% When You Subcribe Annually"
                presentVC.yearlyProduct = yearlyProduct
                presentVC.monthlyProduct = monthlyProduct
            }
        }
    }
    
    fileprivate func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDayPassed), name: .NSCalendarDayChanged, object: nil)
    }
    
    fileprivate func setupPremium(){
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        if !isPremium {
            fetchProducts()
        }
    }
    
    @objc func showDayPassed() {
        let isToday = UserDefaults.standard.bool(forKey: "isToday")
        if !isToday {
            UserDefaults.standard.set(!isToday, forKey: "isToday")
        }
        refresh()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func teardownNotificationCenter(){
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(self, name: .NSCalendarDayChanged, object: nil)

    }
    
    fileprivate func clearEmptyData(){
            refresh()
            for entry in fetchedRC.fetchedObjects! {
                if entry.task.isEmpty {
                    deleteEntry(entry)
                }
            }
        }
    
    fileprivate func setupTimezone(){
        format.timeZone = .current
        let date = Date()
        format.dateFormat = "yyyy-MM-dd"
        
        let dateString = format.string(from: date).split(separator: "-")
        startOfDayComponent.year = Int(dateString[0])
        startOfDayComponent.month = Int(dateString[1])
        
        let isToday = UserDefaults.standard.bool(forKey: "isToday")
        startOfDayComponent.day = Int(dateString[2])

        if isToday {
            dayComponentFrom.day = 0
            dayComponentTo.day = 1
        } else {
            dayComponentFrom.day = 1
            dayComponentTo.day = 2
        }
        
        startOfDayComponent.hour = 0
        startOfDayComponent.minute = 0
        startOfDayComponent.second = 0
    }
    
    
    private func setupSideMenu(){
        let menu = UIStoryboard(name: "SideMenuScreen", bundle: nil).instantiateViewController(identifier: "SideMenuViewController") as! SideMenuViewController
        navigationController?.navigationBar.isHidden = false
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
        sideMenu?.presentationStyle = .menuSlideIn
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0
        view.addSubview(dimmingView)
        self.navigationController?.view.addSubview(dimmingView)
        dimmingView.frame = view.bounds
        addChildControllers()
    }
    
    private func addChildControllers() {
        addChild(profileVC)
        addChild(settingsVC)
        
        view.addSubview(profileVC.view)
        view.addSubview(settingsVC.view)
        
        profileVC.view.frame = view.bounds
        settingsVC.view.frame = view.bounds
        
        profileVC.didMove(toParent: self)
        settingsVC.didMove(toParent: self)
        
        profileVC.view.isHidden = true
        settingsVC.view.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        refresh()
        setupNib()
        setupNotificationCenter()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        tableView.addGestureRecognizer(tap)
        doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickedDone))
        addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAdd))
        navbar.rightBarButtonItem = addBtn
        setupSideMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        teardownNotificationCenter()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        present(sideMenu!, animated: true)
    }
    
    func didSelectMenuItem(row: Int) {
        sideMenu?.dismiss(animated: true, completion: nil)
        view.endEditing(true)
        
        switch row {
        case 0: //ProfileVC
            profileVC.view.isHidden = false
            profileVC.updateEntriesDelegate?.updateEntries()
            profileVC.reloadProfileTableDelegate?.setupTodayDate()
            //TODO: click on today's date manually.
            settingsVC.view.isHidden = true
            floatyQuad.alpha = 0
        case 1: //HomeVC
            profileVC.view.isHidden = true
            settingsVC.view.isHidden = true
            floatyQuad.alpha = 1
        case 2: //SettingsVC
            profileVC.view.isHidden = true
            settingsVC.view.isHidden = false
            floatyQuad.alpha = 0
        default: //HomeVC
            profileVC.view.isHidden = true
            settingsVC.view.isHidden = true
            floatyQuad.alpha = 0
        }
        
    }
    
    
    fileprivate func addNewEntryCell() {
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")

        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows == 0 {
            addEntry(name: "")
            let index = IndexPath(row: numberOfRows, section: 0)
            let cell = tableView.cellForRow(at: index) as! EntryTableViewCell
            selectNextPossibleCellTableTap(cell)
        } else if isPremium || (!isPremium && numberOfRows < 5) {
            let index = IndexPath(row: numberOfRows - 1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: false)
            let cell = tableView.cellForRow(at: index) as! EntryTableViewCell
            if !cell.textView.text.isEmpty {
                addEntry(name: "")
                let newIndex = IndexPath(row: numberOfRows, section: 0)
                tableView.scrollToRow(at: newIndex, at: .bottom, animated: false)
                let cell = tableView.cellForRow(at: newIndex) as! EntryTableViewCell
                selectNextPossibleCellTableTap(cell)
            }
        } else {
            performSegue(withIdentifier: "toPremium", sender: nil)
        }
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        addNewEntryCell()
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0), right: 0)
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
        self.tableView.delegate = self
    }
    
    @objc func clickedDone() {
        editingText(false)
    }
    
    @objc func clickedAdd() {
//        editingText(true)
    }
    
    func editingText(_ isEditingTextStatus: Bool){
        if isEditingTextStatus {
            navbar.rightBarButtonItem = doneBtn
        } else {
            navbar.rightBarButtonItem = nil
            view.endEditing(true)
        }
    }
    
    func toggleBarButton(){
        isEditingText = !isEditingText
        
        if isEditingText {
            navbar.rightBarButtonItem = doneBtn
            //TODO: add entry
        } else {
            navbar.rightBarButtonItem = addBtn
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
        case .delete:
            tableView.deleteRows(at: [cellIndex], with: .fade)
        default:
            break
        }
    }
}

extension HomeViewController: UITableViewDelegate {
}

//MARK: - Tableview Data source
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
        cell.selectCheckboxDelegate = self
        cell.selectionStyle = .none
        
        cell.setCheckboxImage(entry: entry)
        
        cell.textView.text = entry.value(forKey: "task") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = fetchedRC.object(at: indexPath)
            deleteEntry(entry)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            "sectionHeader") as! CustomHeader
        let header = view as UITableViewHeaderFooterView
        let isToday = UserDefaults.standard.bool(forKey: "isToday")

        if isToday {
            view.title.text = "These are your tasks for today."
            header.backgroundView = UIImageView(image: UIImage(named: "header-today-bg"))
        } else {
            view.title.text = "What are you doing for Tomorrow?"
            header.backgroundView = UIImageView(image: UIImage(named: "header-tmr-bg"))
        }
        
        return view
    }
}

extension HomeViewController: TapCheckboxProtocol {
    func selectCheckbox(_ cell: EntryTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: index)
            entry.done = !entry.done
            if entry.done {
                cell.checkbox.setBackgroundImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            } else {
                cell.checkbox.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            }
            appDelegate.saveContext()
        }
    }
}

extension HomeViewController: DeleteEmptyCellDataProtocol {
    func deleteEmptyCellData(_ cell: EntryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: indexPath)
            if entry.task.isEmpty {
                deleteEntry(entry)
            }
        }
    }
}

extension HomeViewController: SaveSelectedCellProtocol {
    func saveSelectedCell(_ cell: EntryTableViewCell, text: String){
        if let index = tableView.indexPath(for: cell) {
            let entry = fetchedRC.object(at: index)
            entry.task = text
            appDelegate.saveContext() //TODO: this is saving every time text changes - might cause performance issues
            profileVC.updateEntriesDelegate?.updateEntries()
        }
    }
}

extension HomeViewController: CellDynamicHeightProtocol {
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


//MARK: - Select Next Cell
extension HomeViewController: SelectNextCellProtocol {
    func selectNextPossibleCell(_ cell: EntryTableViewCell) {
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")

        if let indexPath = tableView.indexPath(for: cell) {
            guard let entriesCount = fetchedRC.fetchedObjects?.count else {return}
            
            if !isPremium && entriesCount >= 5 {
                performSegue(withIdentifier: "toPremium", sender: nil)
                return
            }
            
            if entriesCount - 1 < indexPath.row + 1 {
                addEntry(name: "")
            }
            
            let index = IndexPath(row: indexPath.row + 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            let nextCell = tableView.cellForRow(at: index) as! EntryTableViewCell
            nextCell.textView.becomeFirstResponder()
        }
    }
    
    func selectNextPossibleCellTableTap(_ cell: EntryTableViewCell) {        
        
        if let indexPath = tableView.indexPath(for: cell) {
            let index = IndexPath(row: indexPath.row, section: 0)
            let nextCell = tableView.cellForRow(at: index) as! EntryTableViewCell
            nextCell.textView.becomeFirstResponder()
        }
    }
}

//MARK: - Handle Entries
extension HomeViewController {
    private func refresh() {
        let request = Entry.fetchRequest() as NSFetchRequest<Entry>
        let dateSort = NSSortDescriptor(key: #keyPath(Entry.dateCreated), ascending: true)
        let idSort = NSSortDescriptor(key: #keyPath(Entry.id), ascending: true)

        request.sortDescriptors = [dateSort, idSort]
        setupTimezone()
        
        let dateFrom = calendar.date(byAdding: dayComponentFrom, to: calendar.date(from: startOfDayComponent)!)!
        let dateTo = calendar.date(byAdding: dayComponentTo, to: calendar.date(from: startOfDayComponent)!)!
        print("dateFrom \(dateFrom)")
        print("dateTo \(dateTo)")
        let datePredicateFrom = NSPredicate(format: "dateCreated >= %@", dateFrom as NSDate)
        let datePredicateTo = NSPredicate(format: "dateCreated < %@", dateTo as NSDate)
        request.predicate = datePredicateTo
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicateFrom, datePredicateTo])
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
        
        setupTimezone()
        
        let date = calendar.date(byAdding: dayComponentFrom, to: Date())!
        entry.dateCreated = date
        entry.done = false
        
        let id = UserDefaults.standard.integer(forKey: "globalId")
        entry.id = Int64(id)
        
        UserDefaults.standard.set(id + 1, forKey: "globalId")

        refresh()
        appDelegate.saveContext()
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
        tableView.endUpdates()
    }
    
    fileprivate func deleteEntry(_ entry: Entry) {
        context.delete(entry)
        appDelegate.saveContext()
        refresh()
    }
    
    
}

extension HomeViewController: SideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.dimmingView.alpha = 0.5
        })
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.dimmingView.alpha = 0
        })
    }
}

extension HomeViewController: FloatyDelegate {
    func layoutFABforQuadAnimation(floaty : Floaty) {
        floaty.hasShadow = false
        floaty.fabDelegate = self
        floaty.respondsToKeyboard = false
        
        let editItem = floaty.addItem("", icon: UIImage(systemName: "square.and.pencil")){ _ in
            let alert = UIAlertController(title: "Done For Today", message: "Are you finished with your tasks today?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                let isToday = UserDefaults.standard.bool(forKey: "isToday")
                UserDefaults.standard.set(!isToday, forKey: "isToday")
                print("is it today: \(UserDefaults.standard.bool(forKey: "isToday"))")
                self.refresh()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        editItem.title = "Edit"
        let addItem = floaty.addItem("", icon: UIImage(systemName: "plus")){ _ in
            self.addNewEntryCell()
        }
        addItem.title = "Add"
    }
}

extension HomeViewController: SKProductsRequestDelegate {
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
