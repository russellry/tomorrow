//
//  SignupViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 15/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AuthenticationServices

class SignupViewController: UIViewController {
    
    var name = ""
    var appleLogInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground(name: "onboard-bg")
        nameLabel.text = name
        guard let _ = UserDefaults.standard.object(forKey: "user") as? String else {
            if let token = AccessToken.current, !token.isExpired {
                NSLog("Facebook token is: \(String(describing: AccessToken.current))")
            } else {
                NSLog("Facebook token has expired")
                let fbLoginButton = FBLoginButton()
                fbLoginButton.center = view.center
                fbLoginButton.permissions = ["public_profile", "email"]
                loginStackView.addArrangedSubview(fbLoginButton)
                loginStackView.addArrangedSubview(appleLogInButton)
            }
            return
        }

    }
    
    @objc func handleLogInWithAppleID() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
}

extension SignupViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            
            let defaults = UserDefaults.standard
            defaults.set(userIdentifier, forKey: "user")
            
            performSegue(withIdentifier: "toHomeScreen", sender: nil)
            break
        default:
            break
        }
    }
}

extension SignupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
