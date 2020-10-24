//
//  AccountViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 12/10/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.layer.cornerRadius = 8
        self.title = "Account Info"
        usernameLabel.text = USERNAME
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        guard let newUsername = usernameLabel.text else {return}
        UserDefaults.standard.setValue(newUsername, forKey: "name")
        USERNAME = newUsername
        let changeSuccessTitleText = "Name Changed"
        let changeSuccessMessageText = "Success! - Thank you \(USERNAME)"
        let changeFailedTitleText = "Name Change Failed"
        let changeFailedMessageText = "Not allowed to leave that field empty."
        var titleText = ""
        var messageText = ""
        if USERNAME.isEmpty {
            titleText = changeFailedTitleText
            messageText = changeFailedMessageText
        } else {
            titleText = changeSuccessTitleText
            messageText = changeSuccessMessageText
        }
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
}
