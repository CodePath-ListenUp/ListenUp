//
//  ViewController.swift
//  ListenUp
//
//  Created by Tyler Dakin on 4/6/22.
//

import Parse
import SwiftUI
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func userSubmittedDetails(_ sender: UIButton) {
        // Buttons:
        // tag = 0: Sign Up
        // tag = 1: Log In
        
        let userSignedUp = sender.tag == 0
        
        guard let usernameText = usernameTextField.text, let passwordText = passwordTextField.text else {
            print("User did not enter valid text for either user or pass")
            return
        }
        
        if userSignedUp {
            
        }
        else {
            PFUser.logInWithUsername(inBackground: usernameText, password: passwordText) { user, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
        
    }
    

}

