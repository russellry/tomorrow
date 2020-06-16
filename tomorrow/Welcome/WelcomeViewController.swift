//
//  WelcomeViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 15/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var beenBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground(name: "welcome-bg")
        newBtn.layer.cornerRadius = 8
        beenBtn.layer.cornerRadius = 8
    }
    
    @IBAction func onTapNewBtn(_ sender: Any) {
        performSegue(withIdentifier: "toOnboardingScreen", sender: nil)
    }
}
