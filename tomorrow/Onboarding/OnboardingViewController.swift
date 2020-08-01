//
//  OnboardingViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 14/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameSpacerView: UIView!
    @IBOutlet weak var letsgoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        letsgoBtn.layer.cornerRadius = 8
        letsgoBtn.isEnabled = false
        nameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
//        setBackground(name: "onboard-bg") //TODO: this causes LAG.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignupScreen" {
            let targetController = segue.destination as! SignupViewController
            targetController.name = nameTextField.text!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.becomeFirstResponder()
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let text = textField.text, !text.isEmpty else {
            letsgoBtn.isEnabled = false
            return
        }
        letsgoBtn.isEnabled = true
    }
    
    @IBAction func didTapLetsGoBtn(_ sender: Any) {
        showSignupScreen()
    }
    
    func showSignupScreen() {
        nameTextField.resignFirstResponder()
        performSegue(withIdentifier: "toSignupScreen", sender: nil)
    }
}

extension OnboardingViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameSpacerView.backgroundColor = .systemBlue
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameSpacerView.backgroundColor = .white
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.isEmpty {
            showSignupScreen()
        }
        return true
    }
}
