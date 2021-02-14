//
//  ViewController.swift
//  REST_Exercise
//
//  Created by Dominik Polzer on 11.10.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import UIKit

class LoginViewConroller: UIViewController {
    
    let networking = Networking()
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loadingSymbol: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var keyboardAdjustment: KeyboardAdjustment?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        loadingSymbol.isHidden = true
        keyboardAdjustment = KeyboardAdjustment(scrollView: scrollView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        
        networking.login(email: email, password: password) { (user, error) in
            self.logginIn = false
            if user != nil{
                //self.showAlertControllerWindow(title: "Success", message: "Logged in", actionTitle: "OK")
                self.performSegue(withIdentifier: "succsessfullyLogin", sender: nil)
            }else if let error = error {
                if error == .invalidEmail {
                    self.showAlertControllerWindow(title: "Error", message: "Wrong email was entered", actionTitle: "Cancel")
                }else if error == .invalidPassword {
                    self.showAlertControllerWindow(title: "Error", message: "Wrong password was entered", actionTitle: "Cancel")
                }else if error == .toManyAttempts {
                    self.showAlertControllerWindow(title: "Error", message: "To many attempts. Please try again later", actionTitle: "Cancel")
                }else if error == .emailNotKnown {
                    self.showAlertControllerWindow(title: "Error", message: "Unknown email address", actionTitle: "Cancel")
                }else if error == .requestError("The request timed out."){
                    self.showAlertControllerWindow(title: "Error", message: "Request timed out", actionTitle: "Cancel")
                }else if error == .requestError("The Internet connection appears to be offline."){
                    self.showAlertControllerWindow(title: "Error", message: "No internet connection", actionTitle: "Cancel")
                }else if error == .parsingError {
                    self.showAlertControllerWindow(title: "Error", message: "No User found", actionTitle: "Cancel")
                }
            }
        }
    }
    
    func showAlertControllerWindow(title: String, message: String, actionTitle: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let countryViewController = segue.destination as? CountriesViewController {
            countryViewController.networking = self.networking
        }
    }
}

extension LoginViewConroller: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield{
            passwordTextfield.becomeFirstResponder()
        }else if textField == passwordTextfield{
            save()
        }
        return false
    }
}






