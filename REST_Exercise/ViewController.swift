//
//  ViewController.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 11.10.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var network = Networking()
    let hardcodedEmail: String = ""
    let hardcodedPassword: String = ""
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        loadingSymbol.isHidden = true
    }
    
    var logginIn = false {
        didSet{
            emailTextfield.isEnabled = !logginIn
            passwordTextfield.isEnabled = !logginIn
            loginButton.isEnabled = !logginIn
            loginButton.isHidden = logginIn
            loadingSymbol.isHidden = !logginIn
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        save()
    }
    
    
    func save(){
        self.loadingSymbol.startAnimating()
    
        guard let email = emailTextfield.text, email != "" else{
            let alert = UIAlertController(title: "Error", message: "Please enter an email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            }))
            self.present(alert, animated: true)
            return
        }

        guard let password = passwordTextfield.text, password != "" else{
            let alert = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                   }))
                   self.present(alert, animated: true)
            return
        }

        logginIn = true

        
        network.login(email: email, password: password) { (user, error) in
            self.logginIn = false
            if let user = user{
                let alert = UIAlertController(title: "Success", message: "Logged in", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    print("User that is logged in is \(user.displayName)")
                }))
                self.present(alert, animated: true)
            }else if let error = error {
                
                if error == .invalidEmail {
                    let alert = UIAlertController(title: "Error", message: "Wrong email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action) in
                        self.emailTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }else if error == .invalidPassword {
                    let alert = UIAlertController(title: "Error", message: "Wrong password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action) in
                        self.passwordTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }else if error == .toManyAttempts {
                    let alert = UIAlertController(title: "Error", message: "To many attempts. Please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self.passwordTextfield.text = ""
                        self.emailTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }else if error == .emailNotKnown {
                    let alert = UIAlertController(title: "Error", message: "Unknown Email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: { (action) in
                        self.emailTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }else if error == .requestError("The request timed out."){
                    let alert = UIAlertController(title: "Error", message: "No internet connection", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self.emailTextfield.text = ""
                        self.passwordTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }else if error == .parsingError {
                    let alert = UIAlertController(title: "Error", message: "No User found", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self.emailTextfield.text = ""
                        self.passwordTextfield.text = ""
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield{
            passwordTextfield.becomeFirstResponder()
        }else if textField == passwordTextfield{
            save()
        }
        return false
    }
}



