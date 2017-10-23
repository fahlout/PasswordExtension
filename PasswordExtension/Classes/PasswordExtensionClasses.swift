//
//  PasswordExtensionClasses.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

// MARK: - Login Details

/**
 Login details to be used to as result for credential retrieval, to store new credentials, and to change credentials.
 
 Note: Not all fields are supported by every password manager
 */
public struct PELoginDetails {
    public var urlString: String
    public var username: String
    public var password: String?
    public var oldPassword: String?
    public var title: String?
    public var notes: String?
    public var sectionTitle: String?
    public var fields: [String: Any]?
    public var returnedFields: [String: Any]?
    public var generatedPasswordOptions: PEGeneratedPasswordOptions?
    
    public init(with loginDict: [String: Any]) {
        urlString = loginDict[PELogin.urlString.key()] as? String ?? ""
        username = loginDict[PELogin.username.key()] as? String ?? ""
        password = loginDict[PELogin.password.key()] as? String ?? ""
        oldPassword = loginDict[PELogin.oldPassword.key()] as? String
        title = loginDict[PELogin.title.key()] as? String
        notes = loginDict[PELogin.notes.key()] as? String
        sectionTitle = loginDict[PELogin.sectionTitle.key()] as? String
        fields = loginDict[PELogin.fields.key()] as? [String: Any]
        returnedFields = loginDict[PELogin.returnedFields.key()] as? [String: Any]
        generatedPasswordOptions = loginDict[PELogin.generatedPasswordOptions.key()] as? PEGeneratedPasswordOptions
    }
    
    public init(urlString: String, username: String, password: String? = nil, oldPassword: String? = nil, title: String? = nil, notes: String? = nil, sectionTitle: String? = nil, fields: [String: Any]? = nil, returnedFields: [String: Any]? = nil, generatedPasswordOptions: PEGeneratedPasswordOptions? = nil) {
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
        loginDict[PELogin.urlString.key()] = urlString
        loginDict[PELogin.username.key()] = username
        loginDict[PELogin.password.key()] = password
        loginDict[PELogin.title.key()] = title
        if let oldPassword = oldPassword {
            loginDict[PELogin.oldPassword.key()] = oldPassword
        }
        if let notes = notes {
            loginDict[PELogin.notes.key()] = notes
        }
        if let sectionTitle = sectionTitle {
            loginDict[PELogin.sectionTitle.key()] = sectionTitle
        }
        if let fields = fields {
            loginDict[PELogin.fields.key()] = fields
        }
        if let returnedFields = returnedFields {
            loginDict[PELogin.returnedFields.key()] = returnedFields
        }
        if let generatedPasswordOptions = generatedPasswordOptions {
            loginDict[PELogin.generatedPasswordOptions.key()] = generatedPasswordOptions
        }
        return loginDict
    }
}

// MARK: - Generated Password Options

/**
 Options to be passed to password manager for password generation.
 */
public struct PEGeneratedPasswordOptions {
    public var minLength: Int
    public var maxLength: Int
    
    public init(minLength: Int, maxLength: Int) {
        self.minLength = minLength
        self.maxLength = maxLength
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        var generatedPasswordOptionsDict: [String: Any] = [:]
        generatedPasswordOptionsDict[PEGeneratedPassword.minLength.key()] = minLength
        generatedPasswordOptionsDict[PEGeneratedPassword.maxLength.key()] = maxLength
        return generatedPasswordOptionsDict
    }
}
