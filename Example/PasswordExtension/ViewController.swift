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
        
        // Using built in classes for completion handler
        PasswordExtension.shared.findLoginDetails(for: "https://test.com", viewController: self, sender: nil) { (loginDetails, error) in
            if let loginDetails = loginDetails {
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Password: \(loginDetails.password ?? "")")
                print("URL: \(loginDetails.urlString)")
            } else if let error = error {
                switch error.code {
                case .extensionCancelledByUser:
                    print(error.localizedDescription)
                default:
                    print("Error: \(error)")
                }
            }
        }
        
        // Using raw dictionary for completion handler
//        PasswordExtension.shared.findLoginDict(for: "https://test.com", viewController: self, sender: nil) { (loginDict, error) in
//            if let loginDict = loginDict {
//                print("Title: \(loginDict[PELogin.title.key()] as? String ?? "")")
//                print("Username: \(loginDict[PELogin.username.key()] as? String ?? "")")
//                print("Password: \(loginDict[PELogin.password.key()] as? String ?? "")")
//                print("URL: \(loginDict[PELogin.urlString.key()] as? String ?? "")")
//            } else if let error = error {
//                switch error.code {
//                case .extensionCancelledByUser:
//                    print(error.localizedDescription)
//                default:
//                    print("Error: \(error)")
//                }
//            }
//        }
    }
    
    @IBAction func didTapSaveNewLogin(_ sender: Any) {
        
        // Using built in classes
        let fields = [
            "firstname": "Tim",
            "lastname": "Tester"
        ]
        let loginDetails = PELoginDetails(urlString: "https://test.com", username: "tester1337", password: "test1234", title: "Test App", notes: "Saved with PasswordExtension", fields: fields)
        let generatedPasswordOptions = PEGeneratedPasswordOptions(minLength: 5, maxLength: 45)

        PasswordExtension.shared.storeLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (loginDetails, error) in
            if let loginDetails = loginDetails {
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Password: \(loginDetails.password ?? "")")
                print("URL: \(loginDetails.urlString)")
            } else if let error = error {
                print("Error: \(error)")
            }
        }
        
        // Using dictionaries
//        let fields = [
//            "firstname": "Tim",
//            "lastname": "Tester"
//        ]
//
//        let loginDetails: [String : Any] = [
//            PELogin.urlString.key(): "https://test.com",
//            PELogin.username.key(): "tester1337",
//            PELogin.password.key(): "test1234",
//            PELogin.title.key(): "Test App",
//            PELogin.fields.key(): fields
//        ]
//
//        let generatedPasswordOptions: [String: Any] = [
//            PEGeneratedPassword.minLength.key(): 5,
//            PEGeneratedPassword.maxLength.key(): 45
//        ]
//
//        PasswordExtension.shared.storeLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (loginDict, error) in
//            if let loginDict = loginDict {
//                print("Title: \(loginDict[PELogin.title.key()] as? String ?? "")")
//                print("Username: \(loginDict[PELogin.username.key()] as? String ?? "")")
//                print("Password: \(loginDict[PELogin.password.key()] as? String ?? "")")
//                print("URL: \(loginDict[PELogin.urlString.key()] as? String ?? "")")
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        }
    }
    
    @IBAction func didTapChangePassword(_ sender: Any) {
        
        // Using built in classes
        let loginDetails = PELoginDetails(urlString: "https://test.com", username: "tester1337", title: "Test App")
        let generatedPasswordOptions = PEGeneratedPasswordOptions(minLength: 5, maxLength: 45)

        PasswordExtension.shared.changePasswordForLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (loginDetails, error) in
            if let loginDetails = loginDetails {
                print("Title: \(loginDetails.title ?? "")")
                print("Username: \(loginDetails.username)")
                print("Old Password: \(loginDetails.oldPassword ?? "")")
                print("Password: \(loginDetails.password ?? "")")
                print("URL: \(loginDetails.urlString)")
            } else if let error = error {
                print("Error: \(error)")
            }
        }
        
        // Using dictionaries
//        let loginDetails: [String : Any] = [
//            PELogin.urlString.key(): "https://test.com",
//            PELogin.username.key(): "tester1337",
//            PELogin.title.key(): "Test App"
//        ]
//
//        let generatedPasswordOptions: [String: Any] = [
//            PEGeneratedPassword.minLength.key(): 5,
//            PEGeneratedPassword.maxLength.key(): 45
//        ]
//
//        PasswordExtension.shared.changePasswordForLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (loginDict, error) in
//            if let loginDict = loginDict {
//                print("Title: \(loginDict[PELogin.title.key()] as? String ?? "")")
//                print("Username: \(loginDict[PELogin.username.key()] as? String ?? "")")
//                print("Old Password: \(loginDict[PELogin.oldPassword.key()] as? String ?? "")")
//                print("Password: \(loginDict[PELogin.password.key()] as? String ?? "")")
//                print("URL: \(loginDict[PELogin.urlString.key()] as? String ?? "")")
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        }
    }
}

