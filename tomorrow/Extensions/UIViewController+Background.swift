//
//  UIViewController+Background.swift
//  tomorrow
//
//  Created by Russell Ong on 14/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

extension UIViewController {
    func setBackground(name: String) {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: name)
        backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
}
