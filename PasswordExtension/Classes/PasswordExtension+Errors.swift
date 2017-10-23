//
//  PasswordExtension+Errors.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation



enum PasswordExtensionError: Int {
    case cancelledByUser = 0
    case apiNotAvailable = 1
    case failedToContactExtension = 2
    case failedToLoadItemProviderData = 3
    case collectFieldsScriptFailed = 4
    case fillFieldsScriptFailed = 5
    case unexpectedData = 6
    case failedToObtainURLStringFromWebView = 7
    
    
}

// MARK: - Error
public struct PEError: Error {
    
    public let domain: String = "PasswordExtension"
    public var code: PEError.Code
    public var userInfo: [String: Any]
    public var localizedDescription: String
    
    public init(code: PEError.Code, userInfo: [String: Any]) {
        self.code = code
        self.userInfo = userInfo
        self.localizedDescription = userInfo[NSLocalizedDescriptionKey] as? String ?? ""
    }
    
    public enum Code: Int {
        case systemAppExtensionAPINotAvailable = -1
        case extensionCancelledByUser = -2
        case unexpectedData = -3
        case failedToContactExtension = -4
        case failedToLoadItemProviderData = -5
        case failedToCollectFields = -6
        case failedToObtainUrlStringFromWebView = -7
        case failedToFillFields = -8
    }
}

extension PasswordExtension {
    func systemAppExtensionAPINotAvailableError() -> PEError {
        let userInfo = [NSLocalizedDescriptionKey: "App Extension API is not available in this version of iOS"]
        return PEError(code: .systemAppExtensionAPINotAvailable, userInfo: userInfo)
    }
    
    func extensionCancelledByUserError() -> PEError {
        let userInfo = [NSLocalizedDescriptionKey: "PasswordExtension was cancelled by the user"]
        return PEError(code: .extensionCancelledByUser, userInfo: userInfo)
    }
    
    func failedToContactExtensionError(with activityError: Error?) -> PEError {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to contact the password extension"]
        if activityError != nil {
            userInfo[NSUnderlyingErrorKey] = activityError
        }
        return PEError(code: .failedToContactExtension, userInfo: userInfo)
    }
    
    func unexpectedDataError(with description: String) -> PEError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return PEError(code: .unexpectedData, userInfo: userInfo)
    }
    
    func failedToLoadItemProviderDataError(with underlyingError: Error?) -> PEError {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to parse information returned by password extension"]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return PEError(code: .failedToLoadItemProviderData, userInfo: userInfo)
    }
    
    func failedToCollectFieldsError(with underlyingError: Error?) -> PEError {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to execute script that collects web page information"]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return PEError(code: .failedToCollectFields, userInfo: userInfo)
    }
    
    func failedToObtainURLStringFromWebViewError() -> PEError {
        let userInfo = [NSLocalizedDescriptionKey: "Failed to obtain URL String from web view. The web view must be loaded completely when calling the password extension"]
        return PEError(code: .failedToObtainUrlStringFromWebView, userInfo: userInfo)
    }
    
    func failedToFillFieldsError(with description: String, underlyingError: Error?) -> PEError {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: description]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return PEError(code: .failedToFillFields, userInfo: userInfo)
    }
}
