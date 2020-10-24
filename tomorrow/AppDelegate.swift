
//  AppDelegate.swift

import UIKit
import FBSDKCoreKit
import Firebase
import AuthenticationServices
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /// - Tag: did_finish_launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupUserDefaults()
        FirebaseApp.configure()
        
        //TODO: have a login state management: eg: with userdefaults for loginState, at first always false, after login true -> go to home screen, if false set by logout or first time entry -> go to welcome screen
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        isLoggedIn ? setupHomeScreen() : setupWelcomeScreen()

        if let name = UserDefaults.standard.string(forKey: "name") {
            USERNAME = name
        } else {
            if let user = Auth.auth().currentUser {
                UserDefaults.standard.setValue(user.displayName, forKey: "name")
                USERNAME = user.displayName ?? "New User"
            }
        }
        
        

                
//        if let appleID = UserDefaults.standard.string(forKey: "appleAuthorizedID") {
//            //TODO: avoid using main thread.
//            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: appleID, completion: {
//                credentialState, error in
//                DispatchQueue.main.async {
//                    switch(credentialState){
//                    case .authorized:
//                        print("user remain logged in, proceed to another view")
//                        self.setupHomeScreen()
//                    case .revoked:
//                        print("user logged in before but revoked")
//                        self.setupWelcomeScreen()
//
//                    case .notFound:
//                        print("user haven't log in before")
//                        self.setupWelcomeScreen()
//
//                    default:
//                        print("unknown state")
//                        self.setupWelcomeScreen()
//
//                    }
//                }
//
//            })
//        } else {
//            if let fbID = UserDefaults.standard.string(forKey: "fbName") {
//                USERNAME = fbID
//                setupHomeScreen()
//            } else {
//                setupWelcomeScreen()
//            }
//        }
        return true
    }
    
    fileprivate func setupUserDefaults(){
        UserDefaults.standard.register(defaults: ["isUserLoggedIn": false, "isToday": true, "globalId:": 0])
        UserDefaults.standard.setValue(Date(), forKey: "dateSelected")
    }
    
    fileprivate func setupHomeScreen(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navController = UINavigationController(rootViewController: HOMEVC)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    fileprivate func setupWelcomeScreen() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navVC = UINavigationController(rootViewController: WELCOMEVC)
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
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
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: "EntryModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


