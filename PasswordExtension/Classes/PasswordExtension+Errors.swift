//
//  PasswordExtension+Errors.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

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
    
    func failedToCollectFieldsError(with underlyingError: Error?) -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "Failed to execute script that collects web page information"]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return NSError(domain: errorDomain, code: PasswordExtensionError.collectFieldsScriptFailed.code(), userInfo: userInfo)
    }
    
    func failedToObtainURLStringFromWebViewError() -> Error {
        let userInfo = [NSLocalizedDescriptionKey: "Failed to obtain URL String from web view. The web view must be loaded completely when calling the GenericPassword Extension"]
        return NSError(domain: errorDomain, code: PasswordExtensionError.failedToObtainURLStringFromWebView.code(), userInfo: userInfo)
    }
    
    func failedToFillFieldsError(with description: String, underlyingError: Error?) -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: description]
        if underlyingError != nil {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        return NSError(domain: errorDomain, code: PasswordExtensionError.fillFieldsScriptFailed.code(), userInfo: userInfo)
    }
}
