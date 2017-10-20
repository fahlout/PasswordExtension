//
//  PasswordExtension+ProcessItem.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation
import MobileCoreServices

extension PasswordExtension {
    func processExtensionItem(item: NSExtensionItem, completion: @escaping (PasswordExtensionResponse) -> Void) {
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
                completion(.loginSuccess(loginDetails: PasswordExtensionLoginDetails(with: loginDict), loginDict: loginDict))
            }
        }
    }
}
