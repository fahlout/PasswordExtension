//
//  PasswordExtension+Helpers.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation

extension PasswordExtension {
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
