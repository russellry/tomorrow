//
//  PremiumViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 26/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import StoreKit

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
    var isYearly: Bool = true
    var viewBeingSelected = UIView()
    var viewBeingUnselected = UIView()
    
    var labelBeingSelected = UILabel()
    var labelBeingUnselected = UILabel()
    
    let selectedBgColor: UIColor = UIColor(red: 0.94, green: 0.20, blue: 0.20, alpha: 1.00)
    let unselectedBgColor: UIColor = UIColor(red: 0.87, green: 0.90, blue: 0.91, alpha: 1.00)
    
    var tap = UITapGestureRecognizer()
    
    var product: SKProduct?
    var yearlyProduct: SKProduct?
    var monthlyProduct: SKProduct?

    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    @IBAction func didTapPurchase(_ sender: Any) {
        guard let product = product else {return}
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
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
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case . failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
}
