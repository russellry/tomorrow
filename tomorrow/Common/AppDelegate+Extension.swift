//
//  AppDelegate+Extension.swift
//  tomorrow
//
//  Created by Russell Ong on 5/9/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

extension AppDelegate {
   static var shared: AppDelegate {
      return UIApplication.shared.delegate as! AppDelegate
   }
}
