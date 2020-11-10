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

class SettingsViewController: UITableViewController{

    @IBOutlet weak var onTapManageSubscription: UITableViewCell!
    @IBOutlet weak var onTapAccountInfo: UITableViewCell!
    @IBOutlet weak var onTapLogout: UITableViewCell!

    let format = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let accountTapGesture = UITapGestureRecognizer(target: self, action: #selector(accountTapped))
        let manageSubscriptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(manageSubscriptionTapped))
        onTapLogout.addGestureRecognizer(logoutTapGesture)
        onTapManageSubscription.addGestureRecognizer(manageSubscriptionTapGesture)
        onTapAccountInfo.addGestureRecognizer(accountTapGesture)
    }
    
    @objc func accountTapped(){
        performSegue(withIdentifier: "toAccount", sender: nil)
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
}
