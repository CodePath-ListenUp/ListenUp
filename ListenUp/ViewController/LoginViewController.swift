//
//  ViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/6/22.
//

import AuthenticationServices
import Parse
import ProgressHUD
import SwiftUI
import UIKit

var didRegisterAppleAuthDelegate = false

class AuthDelegate:NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }
    
    func restoreAuthenticationWithAuthData(authData: [String : String]?) -> Bool {
        return true
    }
}

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @IBOutlet weak var appIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "JellyClub"
        
        // new code till line 181
        addSIWAButton()
    }
    
    func addSIWAButton() {
        // Sign In with Apple button
        let signInWithAppleButton = ASAuthorizationAppleIDButton()
        signInWithAppleButton.cornerRadius = 8.0

        // set this so the button will use auto layout constraint
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false

        // add the button to the view controller root view
        self.view.addSubview(signInWithAppleButton)

        // set constraint
        NSLayoutConstraint.activate([
            signInWithAppleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50.0),
            signInWithAppleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50.0),
            signInWithAppleButton.topAnchor.constraint(equalTo: appIcon.bottomAnchor , constant: 20),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])

        // the function that will be executed when user tap the button
        signInWithAppleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // unique ID for each user, this uniqueID will always be returned
            let userID = appleIDCredential.user
            print("UserID: " + userID)
            
            // if needed, save it to user defaults by uncommenting the line below
            // Tyler's edit: probably unnecessary/unwanted. UserDefaults are insecure and we haven't been tying UD to users so far :)
            //UserDefaults.standard.set(appleIDCredential.user, forKey: "userID")
            
            // optional, might be nil
            let email = appleIDCredential.email
            print("Email: " + (email ?? "no email") )
            
            // optional, might be nil
            let givenName = appleIDCredential.fullName?.givenName
            print("Given Name: " + (givenName ?? "no given name") )
            
            // optional, might be nil
            let familyName = appleIDCredential.fullName?.familyName
            print("Family Name: " + (familyName ?? "no family name") )
            
            // optional, might be nil
            let nickName = appleIDCredential.fullName?.nickname
            print("Nick Name: " + (nickName ?? "no nick name") )
            /*
                useful for server side, the app can send identityToken and authorizationCode
                to the server for verification purpose
            */
            var identityToken : String?
            if let token = appleIDCredential.identityToken {
                identityToken = String(bytes: token, encoding: .utf8)
                print("Identity Token: " + (identityToken ?? "no identity token"))
            }

            var authorizationCode : String?
            if let code = appleIDCredential.authorizationCode {
                authorizationCode = String(bytes: code, encoding: .utf8)
                print("Authorization Code: " + (authorizationCode ?? "no auth code") )
            }
            
            // do what you want with the data here
            User.logInWithAuthType(inBackground: "apple", authData: ["token": String(identityToken!), "id": userID]).continueWith { task -> Any? in
                if ((task.error) != nil){
                    //DispatchQueue.main.async {
                        print("Could not login.\nPlease try again.")
                        print("Error with parse login after SIWA: \(task.error!.localizedDescription)")
                    //}
                    return task
                }
                print("Successfuly signed in with Apple")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
                return nil
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
        case .notInteractive:
            print("Not Interactive")
        @unknown default:
            print("Default")
        }
    }
    
    // This is the function that will be executed when user taps the button
    @objc func appleSignInTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        // request full name and email from the user's Apple ID
        request.requestedScopes = [.fullName, .email]

        // pass the request to the initializer of the controller
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        // similar to delegate, this will ask the view controller
        // which window to present the ASAuthorizationController
        authController.presentationContextProvider = self
        
        // delegate functions will be called when user data is
        // successfully retrieved or error occured
        authController.delegate = self
        
        if !didRegisterAppleAuthDelegate {
            User.register(AuthDelegate(), forAuthType: "apple")
            didRegisterAppleAuthDelegate = true
        }
          
        // show the Sign-in with Apple dialog
        authController.performRequests()
    }

//    @IBAction func userSubmittedDetails(_ sender: UIButton) {
//        sender.layer.cornerRadius = 8
//        // Buttons:
//        // tag = 0: Sign Up
//        // tag = 1: Log In
//
//        let userSignedUp = sender.tag == 0
//
//        guard let usernameText = usernameTextField.text, let passwordText = passwordTextField.text else {
//            print("User did not enter valid text for either username or password")
//            ProgressHUD.showError("Please enter both username and password")
//            return
//        }
//
//        ProgressHUD.animationType = .lineScaling
//        ProgressHUD.show("Getting set up...")
//
//        if userSignedUp {
//            let user = User()
//            user.username = usernameText
//            user.password = passwordText
//            user.submittedPosts = []
//            user.upvotedPosts = []
//            user.favoritedPosts = []
//            user.downvotedPosts = []
//
//            user.signUpInBackground { (success, error) in
//                ProgressHUD.dismiss()
//                if success {
//                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
//                    print("\(user.username ?? "") signed up successfully!")
//                } else {
//                    print("Error: \(error?.localizedDescription ?? "")")
//                }
//            }
//        }
//        else {
//            User.logInWithUsername(inBackground: usernameText, password: passwordText) { user, error in
//                ProgressHUD.dismiss()
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//                self.performSegue(withIdentifier: "loginSegue", sender: self)
//            }
//        }
//    }
}

