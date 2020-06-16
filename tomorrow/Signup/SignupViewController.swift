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
    let appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleLoginWithAppleID), for: .touchUpInside)
        return button
    }()
    
    let fbLoginButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleLoginWithFB), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign in with Facebook", for: .normal)
        button.layer.cornerRadius = 8
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
                loginStackView.addArrangedSubview(fbLoginButton)
                loginStackView.addArrangedSubview(appleLoginButton)
            }
            return
        }
        
    }
    
    func saveFBDetails(token: AccessToken) {
        let tokenString = token.tokenString
        let params = ["fields": "first_name, last_name, email"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: tokenString, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in
            
            if let err = error {
                print("Facebook graph request error: \(err)")
            } else {
                print("Facebook graph request successful!")
                
                guard let json = result as? NSDictionary else { return }
                if let email = json["email"] as? String {
                    print("\(email)")
                }
                if let firstName = json["first_name"] as? String {
                    print("\(firstName)")
                }
                if let lastName = json["last_name"] as? String {
                    print("\(lastName)")
                }
                if let id = json["id"] as? String {
                    print("\(id)")
                }
            }
        }
    }
    
    @objc func handleLoginWithFB() {
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile", "email"], viewController: self, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(granted: let granted, declined: let declined, token: let token):
                self.saveFBDetails(token: token)
            case .cancelled:
                print("cancelled")
            case .failed(_):
                print("failed")
            }
        })
    }
    
    @objc func handleLoginWithAppleID() {
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
