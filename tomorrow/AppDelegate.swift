
//  AppDelegate.swift

import UIKit
import FBSDKCoreKit
import Firebase
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /// - Tag: did_finish_launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        guard let obtainedUsername = UserDefaults.standard.object(forKey: "user") as? String else {

            FirebaseApp.configure()
            window?.rootViewController?.showWelcomeScreen()
            return true
        }
        username = obtainedUsername
        FirebaseApp.configure()

        window?.rootViewController = PageViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
    }
    
}


