//
//  PasswordExtension+ProcessItem.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation
import MobileCoreServices

extension PasswordExtension {
    func processExtensionItem(item: NSExtensionItem, completion: @escaping ((loginDetails: PELoginDetails, loginDict: [String: Any])?, _ error: PEError?) -> Void) {
        guard let attachements = item.attachments else {
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToContactExtensionError(with: nil)
                completion(nil, error)
            }
            return
        }
        
        if attachements.count == 0 {
            self.callOnMainThread { [unowned self] () in
                let error = self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item had no attachments.")
                completion(nil, error)
            }
            return
        }
        
        guard let itemProvider = attachements[0] as? NSItemProvider else {
            self.callOnMainThread { [unowned self] () in
                let error = self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item had no attachments.")
                completion(nil, error)
            }
            return
        }
        
        let propertyListKey = kUTTypePropertyList as String
        if !itemProvider.hasItemConformingToTypeIdentifier(propertyListKey) {
            self.callOnMainThread { [unowned self] () in
                let error = self.unexpectedDataError(with: "Unexpected data returned by App Extension: extension item attachment does not conform to kUTTypePropertyList type identifier")
                completion(nil, error)
            }
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: propertyListKey, options: nil) { [unowned self] (loginDict, error) in
            guard let loginDict = loginDict as? [String: Any] else {
                self.callOnMainThread { [unowned self] () in
                    let error = self.failedToLoadItemProviderDataError(with: error)
                    completion(nil, error)
                }
                return
            }
            
            self.callOnMainThread {
                let loginDetails = PELoginDetails(with: loginDict)
                completion((loginDetails, loginDict), nil)
            }
        }
    }
}
