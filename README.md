# PasswordExtension

[![Version](https://img.shields.io/cocoapods/v/PasswordExtension.svg?style=flat)](http://cocoapods.org/pods/PasswordExtension)
[![License](https://img.shields.io/cocoapods/l/PasswordExtension.svg?style=flat)](http://cocoapods.org/pods/PasswordExtension)
[![Platform](https://img.shields.io/cocoapods/p/PasswordExtension.svg?style=flat)](http://cocoapods.org/pods/PasswordExtension)

Rewritten version of [one-password-app-extension by AgileBits](https://github.com/agilebits/onepassword-app-extension) in Swift 4

PasswordExtension lets you give users access to their third party password manager conforming to the PasswordExtension url scheme (i.e. 1Password, LastPass) to fill in their login credentials from their vault, add credentials to their vault, and change their password in their vault for any given url.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 4
- iOS 8 and above

## Installation

PasswordExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PasswordExtension'
```

## Manual Installation

Add all swift files in the 'PasswordExtension/Classes' directory to your project and you'll be ready to go.

## Getting started

In order for your app to be able to fully integrate with this extension the following needs to be added to the Info.plist file in your app to allow the url scheme that password managers like 1Password and LastPass use to check if those apps are installed on the users device.

```XML
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>org-appextension-feature-password-management</string>
</array>
```

You're now ready to use this library to let users fill in credentials, save credentials and change passwords in their password manager vault.

Just add a button with an appropriate icon (i.e. the 1Password icon) to your apps login screen, etc. and show it based on the isAvailable function in PasswordExtension. This button should now be used to invoke the desired PasswordExtension feature.

<img src="https://github.com/fahlout/PasswordExtension/raw/master/Resources/LoginScreen.png" width="320">

***NOTE: Not every field in PasswordExtensionLoginDetails may be supported in every password manager. PasswordExtensionGeneratedPasswordOptions also may or may not be supported depending on the password manager.***

## Example Code

### Find credentials in users' vault

```swift
PasswordExtension.shared.findLogin(for: "https://test.com", viewController: self, sender: nil) { (response) in
    switch response {
    case let .loginSuccess(loginDetails, _):
        print("Title: \(loginDetails.title ?? "")")
        print("Username: \(loginDetails.username)")
        print("Password: \(loginDetails.password)")
        print("URL: \(loginDetails.urlString)")
    case let .error(error):
        print("Error: \(error)")
    default:
        return
    }
}
```

### Store new credentials in users' vault

```swift
let fields = [
    "firstname": "Tim",
    "lastname": "Tester"
]
let loginDetails = PasswordExtensionLoginDetails(urlString: "https://test.com", username: "tester1337", password: "test1234", title: "Test App", notes: "Saved with PasswordExtension", fields: fields)
let generatedPasswordOptions = PasswordExtensionGeneratedPasswordOptions(minLength: 5, maxLength: 45)
        
PasswordExtension.shared.storeLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (response) in
    switch response {
    case let .loginSuccess(loginDetails, _):
        print("Title: \(loginDetails.title ?? "")")
        print("Username: \(loginDetails.username)")
        print("Password: \(loginDetails.password)")
        print("URL: \(loginDetails.urlString)")
    case let .error(error):
        print("Error: \(error)")
    default:
        return
    }
}
```

### Update credentials in users' vault

```swift
let loginDetails = PasswordExtensionLoginDetails(urlString: "https://test.com", username: "tester1337", password: "test4231", oldPassword: "test1234", notes: "Saved with PasswordExtension")
let generatedPasswordOptions = PasswordExtensionGeneratedPasswordOptions(minLength: 5, maxLength: 45)
        
PasswordExtension.shared.changePasswordForLogin(for: loginDetails, generatedPasswordOptions: generatedPasswordOptions, viewController: self, sender: nil) { (response) in
    switch response {
    case let .loginSuccess(loginDetails, _):
        print("Title: \(loginDetails.title ?? "")")
        print("Username: \(loginDetails.username)")
        print("Old Password: \(loginDetails.oldPassword ?? "")")
        print("Password: \(loginDetails.password)")
        print("URL: \(loginDetails.urlString)")
    case let .error(error):
        print("Error: \(error)")
    default:
        return
    }
}
```

## Author

[Niklas Fahl (fahlout)](http://bit.ly/fahlout) - [LinkedIn](http://bit.ly/linked-in-niklas-fahl)

## License

PasswordExtension is available under the MIT license. See the LICENSE file for more info.
