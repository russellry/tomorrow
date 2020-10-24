//
//  SignupViewController.swift
//  tomorrow
//
//  Created by Russell Ong on 15/6/20.
//  Copyright © 2020 trillion.unicorn. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import FBSDKLoginKit
import SKActivityIndicatorView

class WelcomeViewController: UIViewController {
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    var overlayView = UIView()

    @IBOutlet weak var loginStackView: UIStackView!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground(name: "welcome-bg")
        setupAppleLoginView()
        setupFBLoginView()
        setupUI()
    }
    
    fileprivate func setupUI(){
        overlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.7
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

extension WelcomeViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.addSubview(overlayView)
        SKActivityIndicator.show()
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let token = AccessToken.current?.tokenString else {
            print("Facebook token error - user probably cancelled action")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential, completion: { [weak self] (authResult, error) in
            if let error = error {
                print("Facebook authentication with Firebase error: ", error)
                return
            }
            
            let changeRequest = authResult?.user.createProfileChangeRequest()
            changeRequest?.commitChanges(completion: { (error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    let profileName = Auth.auth().currentUser?.displayName ?? "New Apple User"
                    self?.defaults.set(profileName, forKey: "name")
                    USERNAME = profileName
                    print("Updated display name: \(profileName)")
                }
            })
            
            guard let self = self else {return}
            self.defaults.set(true, forKey: "isUserLoggedIn")
            SKActivityIndicator.dismiss()
            self.overlayView.removeFromSuperview()
            self.navigationController?.pushViewController(HOMEVC, animated: true)
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
}

extension WelcomeViewController: ASAuthorizationControllerDelegate {
    
    func setupFBLoginView() {
        let fbLoginButton = FBLoginButton()
        fbLoginButton.delegate = self
        fbLoginButton.permissions = ["public_profile", "email"]
        self.loginStackView.addArrangedSubview(fbLoginButton)
        
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            print("FB Access Token: \(String(describing: AccessToken.current?.tokenString))")
        }
    }
    
    func setupAppleLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {

        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // unique ID for each user, this uniqueID will always be returned
            self.defaults.set(appleIDCredential.user, forKey: "appleAuthorizedID")
            saveUserInKeychain(appleIDCredential.user)
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            var idTokenString : String?
            if let token = appleIDCredential.identityToken {
                idTokenString = String(bytes: token, encoding: .utf8)
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString!,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) {[weak self] (authResult, error) in
                // Mak a request to set user's display name on Firebase
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = appleIDCredential.fullName?.givenName
                changeRequest?.commitChanges(completion: { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let profileName = Auth.auth().currentUser?.displayName ?? ""
                        self?.defaults.set(profileName, forKey: "name")
                        USERNAME = profileName
                        print("Updated display name: \(profileName)")
                    }
                })
                guard let self = self else {return}
                self.defaults.set(true, forKey: "isUserLoggedIn")
                self.navigationController?.pushViewController(HOMEVC, animated: true)
            }
            
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "trillion.unicorn.tomorrow", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
        
    }
}

extension WelcomeViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }
        
        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        @unknown default:
            print("Default")
        }
        
    }
}
