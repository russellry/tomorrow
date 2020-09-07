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

    @IBOutlet weak var onTapLogout: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        let logoutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        onTapLogout.addGestureRecognizer(logoutTapGesture)
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
}
