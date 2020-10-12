//
//  SettingsViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 27/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import StoreKit

class SettingsViewController: UITableViewController, SKProductsRequestDelegate{

    @IBOutlet weak var onTapManageSubscription: UITableViewCell!
    @IBOutlet weak var onTapAccountInfo: UITableViewCell!
    @IBOutlet weak var onTapEditToday: UITableViewCell!
    @IBOutlet weak var onTapLogout: UITableViewCell!
    var product: SKProduct?
    var yearlyProduct: SKProduct?
    var monthlyProduct: SKProduct?
    let format = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.setValue(false, forKey: "is_premium")

        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")

        if !isPremium {
            fetchProducts()
        }
        setupGestures()
    }
    
    fileprivate func showProductAlert(){
        let isPremiumUntil = UserDefaults.standard.object(forKey: "is_premium_until") as! Date
        format.timeZone = .current
        format.dateFormat = "MMM d, yyyy"
        
        let alert = UIAlertController(title: "Purchase Details", message: "Your subscription ends on" + "\n" + format.string(from: isPremiumUntil), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cool!", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    fileprivate func setupGestures() {
        let logoutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        let manageSubscriptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(manageSubscriptionTapped))
        onTapLogout.addGestureRecognizer(logoutTapGesture)
        onTapManageSubscription.addGestureRecognizer(manageSubscriptionTapGesture)
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
    
    @objc func logoutTapped(){
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        NSLog("Logout Tapped")
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        AppDelegate.shared.window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: WELCOMEVC)
        AppDelegate.shared.window?.rootViewController = navVC
        AppDelegate.shared.window?.makeKeyAndVisible()
        //delegate call home view controller to hide the other views?
    }
    
    @objc func manageSubscriptionTapped(){
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")

        if isPremium {
            showProductAlert()
        } else {
            performSegue(withIdentifier: "toPremium", sender: nil)
        }
    }
    
    fileprivate func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: ["tomorrow.monthly.subscription", "tomorrow.yearly.subscription.discount"])
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        yearlyProduct = response.products.last
        monthlyProduct = response.products.first
    }
}
