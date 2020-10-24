//
//  PublicVar.swift
//  tomorrow
//
//  Created by Russell Ong on 18/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//
import Foundation
import UIKit

public var USERNAME = ""
public let SETTINGSVC = UIStoryboard(name: "SettingsScreen", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
public let HOMEVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
public let MENUVC = UIStoryboard(name: "MenuScreen", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController")
public let WELCOMEVC = UIStoryboard(name: "WelcomeScreen", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController")
public let PROFILEVC = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
public let PREMIUMPAGEONE = UIStoryboard(name: "PremiumPagesScreen", bundle: nil).instantiateViewController(withIdentifier: "PremiumPageOneViewController")
public let PREMIUMPAGETWO = UIStoryboard(name: "PremiumPagesScreen", bundle: nil).instantiateViewController(withIdentifier: "PremiumPageTwoViewController")
public let PREMIUMPAGETHREE = UIStoryboard(name: "PremiumPagesScreen", bundle: nil).instantiateViewController(withIdentifier: "PremiumPageThreeViewController")

public var keyStore = NSUbiquitousKeyValueStore()
//TODO: https://medium.com/@janakmshah/quickly-sync-user-data-and-preferences-over-icloud-with-swift-4757a3904f1a
