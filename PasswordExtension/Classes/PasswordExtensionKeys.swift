//
//  PasswordExtensionKeys.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

// MARK: - Login Keys

/**
 Keys to retrieve login details from extension response or to set login details in a dictionary.
 */
public enum PELogin: String {
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

// MARK: - Generated Password Option Keys

/**
 Keys to retrieve or set password generation options in a dictionary.
 */
public enum PEGeneratedPassword: String {
    case minLength = "password_min_length"
    case maxLength = "password_max_length"
    
    public func key() -> String {
        return self.rawValue
    }
}

// MARK: - WebView Dictionary Keys
enum PEWebViewPage: String {
    case fillScript = "fillScript"
    case details = "pageDetails"
    
    func key() -> String {
        return self.rawValue
    }
}

// MARK: - Available App Extension Actions
enum PEActions: String {
    case findLogin = "org.appextension.find-login-action"
    case saveLogin = "org.appextension.save-login-action"
    case changePassword = "org.appextension.change-password-action"
    case fillWebView = "org.appextension.fill-webview-action"
    
    func path() -> String {
        return self.rawValue
    }
}

// MARK: - Extension Path
extension PasswordExtension {
    var extensionPath: String {
        return "org-appextension-feature-password-management://"
    }
}
