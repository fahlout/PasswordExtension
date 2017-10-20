//
//  ViewController.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/19/2017.
//  Copyright (c) 2017 Niklas Fahl. All rights reserved.
//

import UIKit
import PasswordExtension

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapGetPassword(_ sender: Any) {
        PasswordExtension.shared.findLogin(for: "https://test.com", viewController: self, sender: nil) { (response) in
            switch response {
            case let .loginSuccess(loginDetails, _):
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Password: \(loginDetails.password)")
                print("URL: \(loginDetails.urlString)")
            case let .error(error):
                print("Error: \(error)")
            default:
                return
            }
        }
    }
    
    @IBAction func didTapSaveNewLogin(_ sender: Any) {
        let fields = [
            "firstname": "Tim",
            "lastname": "Tester"
        ]
        let loginDetails = PasswordExtensionLoginDetails(urlString: "https://test.com", username: "tester1337", password: "test1234", title: "Test App", notes: "Saved with PasswordExtension", fields: fields)
        let generatedPasswordOptions = PasswordExtensionGeneratedPasswordOptions(minLength: 5, maxLength: 45)
        
        PasswordExtension.shared.storeLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (response) in
            switch response {
            case let .loginSuccess(loginDetails, _):
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Password: \(loginDetails.password)")
                print("URL: \(loginDetails.urlString)")
            case let .error(error):
                print("Error: \(error)")
            default:
                return
            }
        }
    }
    
    @IBAction func didTapChangePassword(_ sender: Any) {
        let loginDetails = PasswordExtensionLoginDetails(urlString: "https://test.com", username: "tester1337", password: "test4231", oldPassword: "test1234", notes: "Saved with PasswordExtension")
        let generatedPasswordOptions = PasswordExtensionGeneratedPasswordOptions(minLength: 5, maxLength: 45)
        
        PasswordExtension.shared.changePasswordForLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (response) in
            switch response {
            case let .loginSuccess(loginDetails, _):
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Old Password: \(loginDetails.oldPassword ?? "")")
                print("Password: \(loginDetails.password)")
                print("URL: \(loginDetails.urlString)")
            case let .error(error):
                print("Error: \(error)")
            default:
                return
            }
        }
    }
}

