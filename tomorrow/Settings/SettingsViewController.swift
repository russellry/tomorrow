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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

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
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: WELCOMEVC)
        appDelegate.window?.rootViewController = navVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
