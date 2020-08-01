//
//  PublicVar.swift
//  tomorrow
//
//  Created by Russell Ong on 18/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//
import Foundation

public var username = UserDefaults.standard.object(forKey: "user") as? String
