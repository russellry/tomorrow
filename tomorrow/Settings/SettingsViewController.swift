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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        
        if !isPremium {
            fetchProducts()
        }
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
            //TODO: set it as "looking at your subscriptions" - what are you subscribed to.
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
