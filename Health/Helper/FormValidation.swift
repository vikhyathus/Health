//
//  FormValidation.swift
//  Health
//
//  Created by Vikhyath on 04/10/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailField:
            nameField.becomeFirstResponder()
        case nameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        default:
            confirmPasswordField.resignFirstResponder()
        }
        return true
    }
    
    func validate(_ textField: UITextField) -> (Bool, String?) {
        
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if textField == passwordField {
            return (text.count >= 6, "Your password is too short.")
        }
        
        if textField == confirmPasswordField {
            return(textField.text == passwordField.text, "Password and confirm password doesn't match")
        }
        
        if textField == emailField {
            return(isValidEmail(testStr: textField.text!), "This is not a valid emailID")
        }
        
        return (!text.isEmpty, "This field cannot be empty.")
    }
    
    @objc func textDidChange(_ notification: Notification) {
        var formIsValid = true
        
        for textField in textFields {
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                signUpButton.alpha = 0.3
                break
            }
        }
        
        signUpButton.isEnabled = formIsValid
        if formIsValid {
            signUpButton.alpha = 1.0
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userName:
            passwordField.becomeFirstResponder()
        default:
            passwordField.resignFirstResponder()
        }
        return true
    }
    
    func validate(_ textField: UITextField) -> (Bool, String?) {
        
        guard let text = textField.text else {
            return (false, nil)
        }
        
        return (!text.isEmpty, "This field cannot be empty.")
    }
    
    @objc func textDidChange(_ notification: Notification) {
        var formIsValid = true
        
        for textField in textFields {
            let (valid, _) = validate(textField)
            
            guard valid else {
                formIsValid = false
                signInButton.alpha = 0.3
                break
            }
        }
        
        signInButton.isEnabled = formIsValid
        if formIsValid {
            signInButton.alpha = 1.0
        }
    }
}
