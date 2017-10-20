//
//  PasswordExtension.swift
//  PasswordAppExtension-Swift
//
//  Created by Niklas Fahl on 10/19/17.
//

import UIKit
import MobileCoreServices

#if _IPHONE_8_0
import WebKit
#endif

// Login Keys
public enum PasswordExtensionLogin: String {
    case urlString = "url_string"
    case username = "username"
    case password = "password"
    case title = "login_title"
    case notes = "notes"
    case sectionTitle = "section_title"
    case fields = "fields"
    case returnedFields = "returned_fields"
    case oldPassword = "old_password"
    case generatedPasswordOptions = "password_generator_options"
    
    public func key() -> String {
        return self.rawValue
    }
}

// Generated Password Option Keys
public enum PasswordExtensionGeneratedPassword: String {
    case minLength = "password_min_length"
    case maxLength = "password_max_length"
    
    public func key() -> String {
        return self.rawValue
    }
}

// WebView Dictionary Keys
enum PasswordExtensionWebViewPage: String {
    case fillScript = "fillScript"
    case details = "pageDetails"
    
    func key() -> String {
        return self.rawValue
    }
}

// Errors Codes
let errorDomain = "GenericPasswordExtension"

enum PasswordExtensionError: Int {
    case cancelledByUser = 0
    case apiNotAvailable = 1
    case failedToContactExtension = 2
    case failedToLoadItemProviderData = 3
    case collectFieldsScriptFailed = 4
    case fillFieldsScriptFailed = 5
    case unexpectedData = 6
    case failedToObtainURLStringFromWebView = 7
    
    func code() -> Int {
        return self.rawValue
    }
}

// Available App Extension Actions
enum PasswordExtensionActions: String {
    case findLogin = "org.appextension.find-login-action"
    case saveLogin = "org.appextension.save-login-action"
    case changePassword = "org.appextension.change-password-action"
    case fillWebView = "org.appextension.fill-webview-action"
    
    func path() -> String {
        return self.rawValue
    }
}

// Note to creators of libraries or frameworks:
// If you include this code within your library, then to prevent potential duplicate symbol
// conflicts for adopters of your library, you should rename the PasswordExtension class.
// You might to so by adding your own project prefix, e.g., MyLibraryPasswordExtension.

public class PasswordExtension {
    
    // Extension Path
    let kExtensionPath = "org-appextension-feature-password-management://"
    
    public static let shared = PasswordExtension()
    
    /*!
     Determines if the password extension is available. Allows you to only show the password extension button to those
     that can use it. Of course, you could leave the button enabled and educate users about the virtues of strong, unique
     passwords instead :)
     
     Note that this returns YES if any app that supports the generic `org-appextension-feature-password-management` feature
     is installed.
     */
    func isAvailable() -> Bool {
        if isSystemAppExtensionAPIAvailable() {
            guard let extensionUrl = URL(string: kExtensionPath) else { return false }
            return UIApplication.shared.canOpenURL(extensionUrl)
        }
        else {
            return false
        }
    }
    
    /*!
     Called from your login page, this method will find all available logins for the given urlString. After the user selects
     a login, it is stored into a dictionary and given to your completion handler. Use the password extension keys above to
     extract the needed information and update your UI.
     */
    public func findLogin(for urlString: String, viewController: UIViewController, sender: Any?, responseType: PasswordExtensionResponseType = .object, completion: @escaping (PasswordExtensionResponse) -> Void) {
        if !isSystemAppExtensionAPIAvailable() {
            print("Failed to find login, system API is not available")
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
            }
        }
        
        if #available(iOS 8, *) {
            // API available, find login
            let item = [PasswordExtensionLogin.urlString.key(): urlString]
            guard let activityVC = activityViewController(for: item, sender: sender, typeIdentifier: PasswordExtensionActions.findLogin.rawValue, completion: { [unowned self] (activityType, completed, items, error) in
                if let error = error {
                    print("Failed to findLogin: \(error)")
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: error)))
                    }
                    return
                }
                
                guard let items = items else {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: nil)))
                    }
                    return
                }
                
                if items.count == 0 {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.extensionCancelledByUserError()))
                    }
                    return
                }
                
                guard let firstItem = items[0] as? NSExtensionItem else {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: nil)))
                    }
                    return
                }
                self.processExtensionItem(item: firstItem, responseType: responseType, completion: completion)
            })
            else {
                print("Failed to find login, system API is not available")
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
                }
                return
            }
            viewController.present(activityVC, animated: true, completion: nil)
        }
        else {
            print("Failed to find login, system API is not available")
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
            }
        }
    }
    
    /*!
     Create a new login and allow the user to generate a new password before saving. The provided urlString should be
     unique to your app or service and be identical to what you pass into the find login method.
     
     Details about the saved login, including the generated password, are stored in a dictionary and given to your completion handler.
     Use the password extension keys above to extract the needed information and update your UI. For example, updating the UI with the
     newly generated password lets the user know their action was successful.
     */
    public func storeLogin(for loginDetails: PasswordExtensionLoginDetails, generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions?, viewController: UIViewController, sender: Any?, responseType: PasswordExtensionResponseType = .object, completion: @escaping (PasswordExtensionResponse) -> Void) {
        if !isSystemAppExtensionAPIAvailable() {
            print("Failed to find login, system API is not available")
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
            }
        }
        
        if #available(iOS 8, *) {
            var loginAttributes: [String: Any] = loginDetails.dictionaryRepresentation()
            if let generatedPasswordOptions = generatedPasswordOptions?.dictionaryRepresentation() {
                loginAttributes[PasswordExtensionLogin.generatedPasswordOptions.key()] = generatedPasswordOptions
            }
            
            guard let activityVC = activityViewController(for: loginAttributes, sender: sender, typeIdentifier: PasswordExtensionActions.saveLogin.path(), completion: { [unowned self] (activityType, completed, items, error) in
                if let error = error {
                    print("Failed to storeLogin: \(error)")
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: error)))
                    }
                    return
                }
                
                guard let items = items else {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: nil)))
                    }
                    return
                }
                
                if items.count == 0 {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.extensionCancelledByUserError()))
                    }
                    return
                }
                
                guard let firstItem = items[0] as? NSExtensionItem else {
                    self.callOnMainThread { [unowned self] () in
                        completion(.error(error: self.failedToContactExtensionError(with: nil)))
                    }
                    return
                }
                self.processExtensionItem(item: firstItem, responseType: responseType, completion: completion)
            })
            else {
                print("Failed to find login, system API is not available")
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
                }
                return
            }
            viewController.present(activityVC, animated: true, completion: nil)
        }
        else {
            print("Failed to find login, system API is not available")
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
            }
        }
    }
    
    /*!
     Change the password for an existing login. The provided urlString should be
     unique to your app or service and be identical to what you pass into the find login method. The username must be the one that the user is currently logged in with.
     Details about the saved login, including the newly generated and the old password, are stored in a dictionary and given to your completion handler.
     Use the password extension keys above to extract the needed information and update your UI. For example, updating the UI with the
     newly generated password lets the user know their action was successful.
     */
    public func changePasswordForLogin(for urlString: String, loginDetails: PasswordExtensionLoginDetails, generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions, viewController: UIViewController, sender: Any?, responseType: PasswordExtensionResponseType = .object, completion: (PasswordExtensionResponse) -> Void) {
        
    }
    
    /*!
     Called from your web view controller, this method will show all the saved logins for the active page in the provided web
     view, and automatically fill the HTML form fields. Supports both WKWebView and UIWebView.
     */
    public func fillLogin(for webView: Any, viewController: UIViewController, sender: Any?, completion: (PasswordExtensionResponse) -> Void) {
        
    }
}

extension PasswordExtension {
    func isSystemAppExtensionAPIAvailable() -> Bool {
        if #available(iOS 8, *) { return true } else { return false }
    }
    
    func callOnMainThread(completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        }
        else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension PasswordExtension {
    func activityViewController(for item: [String: Any], sender: Any?, typeIdentifier: String, completion: @escaping (UIActivityType?, Bool, [Any]?, Error?) -> Void) -> UIActivityViewController? {
        let itemProvider = NSItemProvider(item: item as NSSecureCoding, typeIdentifier: typeIdentifier)
        
        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [itemProvider]
        
        let activityViewController = UIActivityViewController(activityItems: [extensionItem], applicationActivities: nil)
        if let sender = sender {
            if sender is UIBarButtonItem {
                activityViewController.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
            }
            else if sender is UIView {
                activityViewController.popoverPresentationController?.sourceView = (sender as! UIView).superview
                activityViewController.popoverPresentationController?.sourceRect = (sender as! UIView).frame
            }
        }
        activityViewController.completionWithItemsHandler = completion
        return activityViewController
    }
}

extension PasswordExtension {
    func processExtensionItem(item: NSExtensionItem, responseType: PasswordExtensionResponseType, completion: @escaping (PasswordExtensionResponse) -> Void) {
        guard let attachements = item.attachments else {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToContactExtensionError(with: nil)))
            }
            return
        }
        
        if attachements.count == 0 {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item had no attachments.")))
            }
            return
        }
        
        guard let itemProvider = attachements[0] as? NSItemProvider else {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item had no attachments.")))
            }
            return
        }
        
        let propertyListKey = kUTTypePropertyList as String
        if !itemProvider.hasItemConformingToTypeIdentifier(propertyListKey) {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item attachment does not conform to kUTTypePropertyList type identifier")))
            }
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: propertyListKey, options: nil) { [unowned self] (loginDict, error) in
            guard let loginDict = loginDict as? [String: Any] else {
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.failedToLoadItemProviderDataError(with: error)))
                }
                return
            }
            
            self.callOnMainThread {
                if responseType == .dictionary {
                    completion(.successWithLoginDetailsDict(dict: loginDict))
                } else {
                    completion(.successWithLoginDetails(model: PasswordExtensionLoginDetails(with: loginDict)))
                }
            }
        }
    }
}

// MARK: - Errors

extension PasswordExtension {
    func systemAppExtensionAPINotAvailableError() -> Error {
        let userInfo = [NSLocalizedDescriptionKey: "App Extension API is not available in this version of iOS"]
        return NSError(domain: errorDomain, code: PasswordExtensionError.apiNotAvailable.code(), userInfo: userInfo)
    }
    
    func extensionCancelledByUserError() -> Error {
        let userInfo = [NSLocalizedDescriptionKey: "GenericPassword Extension was cancelled by the user"]
        return NSError(domain: errorDomain, code: PasswordExtensionError.cancelledByUser.code(), userInfo: userInfo)
    }
    
    func failedToContactExtensionError(with activityError: Error?) -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to contact the GenericPassword Extension"]
        if activityError != nil {
            userInfo[NSUnderlyingErrorKey] = activityError
        }
        return NSError(domain: errorDomain, code: PasswordExtensionError.cancelledByUser.code(), userInfo: userInfo)
    }
    
    func unexpectedDataError(with description: String) -> Error {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: errorDomain, code: PasswordExtensionError.unexpectedData.code(), userInfo: userInfo)
    }
    
    func failedToLoadItemProviderDataError(with underlyingError: Error?) -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to parse information returned by GenericPassword Extension"]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return NSError(domain: errorDomain, code: PasswordExtensionError.failedToLoadItemProviderData.code(), userInfo: userInfo)
    }
}
