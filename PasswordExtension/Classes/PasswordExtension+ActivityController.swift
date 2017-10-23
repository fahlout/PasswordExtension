//
//  PasswordExtension+ActivityController.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

extension PasswordExtension {
    func presentActivityViewController(for item: [String: Any], viewController: UIViewController, sender: Any?, typeIdentifier: String, completion: @escaping ((loginDetails: PELoginDetails, loginDict: [String: Any])?, _ error: PEError?) -> Void) {
        guard let activityVC = activityViewController(for: item, sender: sender, typeIdentifier: typeIdentifier, completion: { [unowned self] (activityType, completed, items, error) in
            self.handleActivityViewControllerCompletion(activityType: activityType, completed: completed, items: items, error: error, completion: completion)
        })
            else {
                print("Failed to find login, system API is not available")
                self.callOnMainThread { [unowned self] () in
                    let error = self.systemAppExtensionAPINotAvailableError()
                    completion(nil, error)
                }
                return
        }
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
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
    
    func handleActivityViewControllerCompletion(activityType: UIActivityType?, completed: Bool, items: [Any]?, error: Error?, completion: @escaping ((loginDetails: PELoginDetails, loginDict: [String: Any])?, _ error: PEError?) -> Void) {
        if let error = error {
            print("Failed to contact extension: \(error)")
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToContactExtensionError(with: error)
                completion(nil, error)
            }
            return
        }
        
        guard let items = items else {
            self.callOnMainThread { [unowned self] () in
                let error = self.extensionCancelledByUserError()
                completion(nil, error)
            }
            return
        }
        
        if items.count == 0 {
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToContactExtensionError(with: nil)
                completion(nil, error)
            }
            return
        }
        
        guard let firstItem = items[0] as? NSExtensionItem else {
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToContactExtensionError(with: nil)
                completion(nil, error)
            }
            return
        }
        self.processExtensionItem(item: firstItem, completion: completion)
    }
}
