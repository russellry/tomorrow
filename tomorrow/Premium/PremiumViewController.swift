//
//  PremiumViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 26/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import SKActivityIndicatorView
import Purchases

@objc protocol SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PremiumViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
    @objc optional func purchaseFailed(paywall: PremiumViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
    @objc optional func purchaseRestored(paywall: PremiumViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}

class PremiumViewController: UIViewController {
    var paywallDelegate : SwiftPaywallDelegate?

    @IBOutlet weak var navCloseBtn: UIBarButtonItem!
    @IBOutlet weak var mostPopularView: UIView!
    @IBOutlet weak var mostFlexibleView: UIView!
    @IBOutlet weak var pricingStackView: UIStackView!
    
    @IBOutlet weak var mostPopularLabel: UILabel!
    @IBOutlet weak var mostFlexibleLabel: UILabel!
    
    @IBOutlet weak var yearlyLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var monthlyDiscountLabel: UILabel!
    
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
    
    private var offeringId : String?
    
    private var offering : Purchases.Offering?
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paywallDelegate = self
        setupUI()
        setupGestures()
    }
    
    @IBAction func didTapPurchase(_ sender: Any) {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(overlayView)
        SKActivityIndicator.show()

        let yearlyPackage: Purchases.Package?
        let monthlyPackage: Purchases.Package?
        let package: Purchases.Package?
        if offering?.availablePackages[0].product.productIdentifier == "tomorrow.monthly.subscription" {
            monthlyPackage = offering?.availablePackages[0]
            yearlyPackage = offering?.availablePackages[1]
        } else {
            monthlyPackage = offering?.availablePackages[1]
            yearlyPackage = offering?.availablePackages[0]
        }

        if isYearly {
            package = yearlyPackage
        } else {
            package = monthlyPackage
        }
        
        
        Purchases.shared.purchasePackage(package!) { (trans, info, error, cancelled) in
            if let error = error {
                if let purchaseFailedHandler = self.paywallDelegate?.purchaseFailed {
                    purchaseFailedHandler(self, info, error, cancelled)
                } else {
                    self.showAlert(title: "Purchase Failed", message: error.localizedDescription, actionTitle: "OK")
                }
            } else  {
                if let purchaseCompletedHandler = self.paywallDelegate?.purchaseCompleted {
                    purchaseCompletedHandler(self, trans!, info!)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            SKActivityIndicator.dismiss()
            self.overlayView.removeFromSuperview()
        }
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(overlayView)
        SKActivityIndicator.show()

        Purchases.shared.restoreTransactions { (info, error) in
            if let purchaseRestoredHandler = self.paywallDelegate?.purchaseRestored {
                purchaseRestoredHandler(self, info, error)
            } else {
                if let error = error {
                    self.showAlert(title: "Restore Failed", message: error.localizedDescription, actionTitle: "OK")
                } else {
                    if let purchaserInfo = info {
                        if purchaserInfo.entitlements.active.isEmpty {
                            self.showAlert(title: "Restore Failed", message: "Restore Unsuccessful", actionTitle: "OK")
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            SKActivityIndicator.dismiss()
            self.overlayView.removeFromSuperview()
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
        
        Purchases.shared.offerings { (offerings, error) in
            
            if error != nil {
                NSLog(error.debugDescription)
            }
            
            if let monthlyPrice = offerings?.current?.monthly?.product {
                self.monthlyLabel.text = monthlyPrice.localizedPrice
            }
            if let yearlyPrice = offerings?.current?.annual?.product {
                self.yearlyLabel.text = yearlyPrice.localizedPrice + "*"
            }
            self.monthlyDiscountLabel.text = "*Save 25% when you Subscribe Annually"
            
            if let offeringId = self.offeringId {
                self.offering = offerings?.offering(identifier: offeringId)
            } else {
                self.offering = offerings?.current
            }
            
            if self.offering == nil {
                NSLog("no offerings found")
            }
        }
        
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
    
    fileprivate func showAlert(title: String, message: String, actionTitle: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
}

extension PremiumViewController: SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PremiumViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo) {
        UserDefaults.standard.setValue(true, forKey: "is_premium")
        let expiryDate = purchaserInfo.expirationDate(forEntitlement: "premium")
        UserDefaults.standard.setValue(expiryDate, forKey: "is_premium_until")
        print("purchase completed")
        dismiss(animated: true, completion: nil)
    }
    
    func purchaseRestored(paywall: PremiumViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?) {
        UserDefaults.standard.setValue(true, forKey: "is_premium")
        guard let expiryDate = purchaserInfo?.expirationDate(forEntitlement: "premium") else {
            return
        }
        UserDefaults.standard.setValue(expiryDate, forKey: "is_premium_until")
        print("purchase restored")
        dismiss(animated: true, completion: nil)
    }
    
    func purchaseFailed(paywall: PremiumViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool) {
        print("purchase failed")
    }
}
