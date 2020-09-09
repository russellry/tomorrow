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
    @IBOutlet weak var onTapEditToday: UITableViewCell!
    @IBOutlet weak var onTapLogout: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        let logoutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        let editTapGesture = UITapGestureRecognizer(target: self, action: #selector(editTapped))

        onTapLogout.addGestureRecognizer(logoutTapGesture)
        onTapEditToday.addGestureRecognizer(editTapGesture)

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
    
    @objc func editTapped(){
        let isEditToday = UserDefaults.standard.bool(forKey: "editToday")
        UserDefaults.standard.set(!isEditToday, forKey: "editToday")
        NSLog("Edit Tapped")
        
    }
}
