//
//  SignupViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 15/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    var name = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground(name: "onboard-bg")
        nameLabel.text = name
    }
}
