//
//  LoginViewController.swift
//  KeyboardExample
//
//  Created by Claire Reynaud on 17/10/2017.
//  Copyright © 2017 Claire Reynaud EIRL. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        login()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login()
        }
        return false
    }
    
    func login() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, email != "" else {
            showAlert(title: "Erreur", message: "L'identifiant de l'utilisateur ne peut pas être vide")
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            showAlert(title: "Erreur", message: "Le mot de passe de l'utilisateur ne peut pas être vide")
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Connexion en cours..."
        
        APIRequestManager.login(username: email, password: password) { (error) in
            hud.hide(animated: true)
            
            if let error = error {
                print("Error: \(error)")
                self.showAlert(title: "Erreur", message: error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion:nil)
    }
}
