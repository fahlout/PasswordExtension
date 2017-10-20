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
