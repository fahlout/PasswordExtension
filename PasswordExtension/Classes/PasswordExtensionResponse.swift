//
//  PasswordExtensionResponse.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

public enum PasswordExtensionResponse {
    case loginSuccess(loginDetails: PasswordExtensionLoginDetails, loginDict: [String: Any])
    case success(success: Bool)
    case error(error: Error)
}

public enum PasswordExtensionResponseType {
    case dictionary
    case object
}

// Note: Not all fields are supported by every password manager
public struct PasswordExtensionLoginDetails {
    public var urlString: String
    public var username: String
    public var password: String
    public var oldPassword: String?
    public var title: String?
    public var notes: String?
    public var sectionTitle: String?
    public var fields: [String: Any]?
    public var returnedFields: [String: Any]?
    public var generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions?
    
    public init(with loginDict: [String: Any]) {
        urlString = loginDict[PasswordExtensionLogin.urlString.key()] as? String ?? ""
        username = loginDict[PasswordExtensionLogin.username.key()] as? String ?? ""
        password = loginDict[PasswordExtensionLogin.password.key()] as? String ?? ""
        oldPassword = loginDict[PasswordExtensionLogin.oldPassword.key()] as? String
        title = loginDict[PasswordExtensionLogin.title.key()] as? String
        notes = loginDict[PasswordExtensionLogin.notes.key()] as? String
        sectionTitle = loginDict[PasswordExtensionLogin.sectionTitle.key()] as? String
        fields = loginDict[PasswordExtensionLogin.fields.key()] as? [String: Any]
        returnedFields = loginDict[PasswordExtensionLogin.returnedFields.key()] as? [String: Any]
        generatedPasswordOptions = loginDict[PasswordExtensionLogin.generatedPasswordOptions.key()] as? PasswordExtensionGeneratedPasswordOptions
    }
    
    public init(urlString: String, username: String, password: String, oldPassword: String? = nil, title: String? = nil, notes: String? = nil, sectionTitle: String? = nil, fields: [String: Any]? = nil, returnedFields: [String: Any]? = nil, generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions? = nil) {
        self.urlString = urlString
        self.username = username
        self.password = password
        self.oldPassword = oldPassword
        self.title = title
        self.notes = notes
        self.sectionTitle = sectionTitle
        self.fields = fields
        self.returnedFields = returnedFields
        self.generatedPasswordOptions = generatedPasswordOptions
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        var loginDict: [String: Any] = [:]
        loginDict[PasswordExtensionLogin.urlString.key()] = urlString
        loginDict[PasswordExtensionLogin.username.key()] = username
        loginDict[PasswordExtensionLogin.password.key()] = password
        loginDict[PasswordExtensionLogin.title.key()] = title
        if let oldPassword = oldPassword {
            loginDict[PasswordExtensionLogin.oldPassword.key()] = oldPassword
        }
        if let notes = notes {
            loginDict[PasswordExtensionLogin.notes.key()] = notes
        }
        if let sectionTitle = sectionTitle {
            loginDict[PasswordExtensionLogin.sectionTitle.key()] = sectionTitle
        }
        if let fields = fields {
            loginDict[PasswordExtensionLogin.fields.key()] = fields
        }
        if let returnedFields = returnedFields {
            loginDict[PasswordExtensionLogin.returnedFields.key()] = returnedFields
        }
        if let generatedPasswordOptions = generatedPasswordOptions {
            loginDict[PasswordExtensionLogin.generatedPasswordOptions.key()] = generatedPasswordOptions
        }
        return loginDict
    }
}

public struct PasswordExtensionGeneratedPasswordOptions {
    public var minLength: Int
    public var maxLength: Int
    
    public init(minLength: Int, maxLength: Int) {
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        var generatedPasswordOptionsDict: [String: Any] = [:]
        generatedPasswordOptionsDict[PasswordExtensionGeneratedPassword.minLength.key()] = minLength
        generatedPasswordOptionsDict[PasswordExtensionGeneratedPassword.maxLength.key()] = maxLength
        return generatedPasswordOptionsDict
    }
}
