//
//  PublicVar.swift
//  tomorrow
//
//  Created by Russell Ong on 18/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//
import Foundation
import UIKit

public var USERNAME = (UserDefaults.standard.object(forKey: "user") != nil) ? UserDefaults.standard.object(forKey: "user") : UserDefaults.standard.object(forKey: "applename")
public let SETTINGSVC = UIStoryboard(name: "SettingsScreen", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController")
public let HOMEVC = UIStoryboard(name: "HomeScreen", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
public let MENUVC = UIStoryboard(name: "MenuScreen", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController")
public let WELCOMEVC = UIStoryboard(name: "WelcomeScreen", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController")
public let PROFILEVC = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
public var keyStore = NSUbiquitousKeyValueStore()
//TODO: https://medium.com/@janakmshah/quickly-sync-user-data-and-preferences-over-icloud-with-swift-4757a3904f1a
