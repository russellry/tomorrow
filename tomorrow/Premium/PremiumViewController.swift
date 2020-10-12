//
//  PremiumViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 26/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import StoreKit
import SKActivityIndicatorView

class PremiumViewController: UIViewController {
    
    @IBOutlet weak var navCloseBtn: UIBarButtonItem!
    @IBOutlet weak var mostPopularView: UIView!
    @IBOutlet weak var mostFlexibleView: UIView!
    @IBOutlet weak var pricingStackView: UIStackView!
    
    @IBOutlet weak var mostPopularLabel: UILabel!
    @IBOutlet weak var mostFlexibleLabel: UILabel!
    
    @IBOutlet weak var yearlyLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var monthlyDiscountLabel: UILabel!
    
    var yearlyLabelText = ""
    var monthlyLabelText = ""
    var monthlyDiscountLabelText = ""
    
    var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    var overlayView = UIView()
    var isYearly: Bool = true
    var viewBeingSelected = UIView()
    var viewBeingUnselected = UIView()
    
    var labelBeingSelected = UILabel()
    var labelBeingUnselected = UILabel()
    
    let selectedBgColor: UIColor = UIColor(red: 0.94, green: 0.20, blue: 0.20, alpha: 1.00)
    let unselectedBgColor: UIColor = UIColor(red: 0.87, green: 0.90, blue: 0.91, alpha: 1.00)
    
    var tap = UITapGestureRecognizer()
    
    var product: SKProduct?
    var monthlyProduct: SKProduct?
    var yearlyProduct: SKProduct?
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    @IBAction func didTapPurchase(_ sender: Any) {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(overlayView)
        SKActivityIndicator.show()
        
        if isYearly {
            product = yearlyProduct
        } else {
            product = monthlyProduct
        }
        
        guard let product = product else {return}
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(overlayView)
        SKActivityIndicator.show()
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        isYearly = !isYearly
        
        feedbackGenerator?.selectionChanged()
        feedbackGenerator?.prepare()
        
        if isYearly {
            viewBeingSelected = mostPopularView
            viewBeingUnselected = mostFlexibleView
            labelBeingSelected = mostPopularLabel
            labelBeingUnselected = mostFlexibleLabel
        } else {
            viewBeingSelected = mostFlexibleView
            viewBeingUnselected = mostPopularView
            labelBeingSelected = mostFlexibleLabel
            labelBeingUnselected = mostPopularLabel
        }
        
        labelBeingSelected.textColor = .white
        labelBeingUnselected.textColor = .black
        
        viewBeingUnselected.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.viewBeingSelected.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            self?.labelBeingSelected.backgroundColor = self?.selectedBgColor
            self?.labelBeingUnselected.backgroundColor = self?.unselectedBgColor
        }) { (finished) in
            UIView.animate(withDuration: 0.05, animations: {
                self.viewBeingSelected.transform = CGAffineTransform.identity
            })
        }
    }
    
    fileprivate func setupUI(){
        pricingStackView.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
        pricingStackView.isLayoutMarginsRelativeArrangement = true
        
        navCloseBtn.tintColor = selectedBgColor
        mostPopularView.layer.cornerRadius = 16
        mostFlexibleView.layer.cornerRadius = 16
        mostPopularView.clipsToBounds = true
        mostFlexibleView.clipsToBounds = true
        
        mostPopularLabel.backgroundColor = selectedBgColor
        mostFlexibleLabel.backgroundColor = unselectedBgColor
        
        continueBtn.backgroundColor = selectedBgColor
        continueBtn.layer.cornerRadius = 8
        
        restoreBtn.setTitleColor(selectedBgColor, for: .normal)
        labelBeingSelected.textColor = .white
        labelBeingUnselected.textColor = .black
        
        yearlyLabel.text = yearlyLabelText
        monthlyLabel.text = monthlyLabelText
        monthlyDiscountLabel.text = monthlyDiscountLabelText
        
        overlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.7
    }
    
    fileprivate func setupGestures() {
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
        tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        mostFlexibleView.addGestureRecognizer(tap)
    }
    
    @IBAction func onTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func dismiss(){
        let alert = UIAlertController(title: "Purchase Restored", message: "You have already purchased this item.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
}

extension PremiumViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                //no op
                break
            case .purchased, .restored:
                UserDefaults.standard.setValue(true, forKey: "is_premium")
                var expiryDate: Date?
                if transaction.payment.productIdentifier == "tomorrow.monthly.subscription" {
                    expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: transaction.transactionDate!)
                } else if transaction.payment.productIdentifier == "tomorrow.yearly.subscription" {
                    expiryDate = Calendar.current.date(byAdding: .year, value: 1, to: transaction.transactionDate!)
                }
                
                guard let expDate = expiryDate else {return}
                
                switch expDate.compare(Date()) {
                
                case .orderedAscending:
                    print("Exp date is earlier than current")
                    //no op
                case .orderedSame:
                    print("Exp date same as current")
                case .orderedDescending:
                    print("Exp date is later than current")
                    UserDefaults.standard.setValue(expiryDate, forKey: "is_premium_until")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                SKActivityIndicator.dismiss()
                overlayView.removeFromSuperview()
                
                dismiss()
                break
            case . failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                SKActivityIndicator.dismiss()
                overlayView.removeFromSuperview()
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                SKActivityIndicator.dismiss()
                overlayView.removeFromSuperview()
                break
            }
        }
        
    }
}
