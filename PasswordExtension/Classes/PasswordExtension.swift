//
//  PasswordExtension.swift
//  PasswordAppExtension-Swift
//
//  Created by Niklas Fahl on 10/19/17.
//

import UIKit
import MobileCoreServices
import WebKit

// Login Keys
public enum PasswordExtensionLogin: String {
    case urlString = "url_string"
    case username = "username"
    case password = "password"
    case title = "login_title"
    case notes = "notes"
    case sectionTitle = "section_title"
    case fields = "fields"
    case returnedFields = "returned_fields"
    case oldPassword = "old_password"
    case generatedPasswordOptions = "password_generator_options"
    
    public func key() -> String {
        return self.rawValue
    }
}

// Generated Password Option Keys
public enum PasswordExtensionGeneratedPassword: String {
    case minLength = "password_min_length"
    case maxLength = "password_max_length"
    
    public func key() -> String {
        return self.rawValue
    }
}

// WebView Dictionary Keys
enum PasswordExtensionWebViewPage: String {
    case fillScript = "fillScript"
    case details = "pageDetails"
    
    func key() -> String {
        return self.rawValue
    }
}

// Errors Codes
let errorDomain = "GenericPasswordExtension"

enum PasswordExtensionError: Int {
    case cancelledByUser = 0
    case apiNotAvailable = 1
    case failedToContactExtension = 2
    case failedToLoadItemProviderData = 3
    case collectFieldsScriptFailed = 4
    case fillFieldsScriptFailed = 5
    case unexpectedData = 6
    case failedToObtainURLStringFromWebView = 7
    
    func code() -> Int {
        return self.rawValue
    }
}

// Available App Extension Actions
enum PasswordExtensionActions: String {
    case findLogin = "org.appextension.find-login-action"
    case saveLogin = "org.appextension.save-login-action"
    case changePassword = "org.appextension.change-password-action"
    case fillWebView = "org.appextension.fill-webview-action"
    
    func path() -> String {
        return self.rawValue
    }
}

// Note to creators of libraries or frameworks:
// If you include this code within your library, then to prevent potential duplicate symbol
// conflicts for adopters of your library, you should rename the PasswordExtension class.
// You might to so by adding your own project prefix, e.g., MyLibraryPasswordExtension.

public class PasswordExtension {
    
    // Extension Path
    let kExtensionPath = "org-appextension-feature-password-management://"
    
    public static let shared = PasswordExtension()
    
    /*!
     Determines if the password extension is available. Allows you to only show the password extension button to those
     that can use it. Of course, you could leave the button enabled and educate users about the virtues of strong, unique
     passwords instead :)
     
     Note that this returns YES if any app that supports the generic `org-appextension-feature-password-management` feature
     is installed.
     */
    func isAvailable() -> Bool {
        guard let extensionUrl = URL(string: kExtensionPath) else { return false }
        return UIApplication.shared.canOpenURL(extensionUrl)
    }
    
    /*!
     Called from your login page, this method will find all available logins for the given urlString. After the user selects
     a login, it is stored into a dictionary and given to your completion handler. Use the password extension keys above to
     extract the needed information and update your UI.
     */
    public func findLogin(for urlString: String, viewController: UIViewController, sender: Any?, completion: @escaping (PasswordExtensionResponse) -> Void) {
        let item = [PasswordExtensionLogin.urlString.key(): urlString]
        
        presentActivityViewController(for: item, viewController: viewController, sender: sender, typeIdentifier: PasswordExtensionActions.findLogin.path(), completion: completion)
    }
    
    /*!
     Create a new login and allow the user to generate a new password before saving. The provided urlString should be
     unique to your app or service and be identical to what you pass into the find login method.
     
     Details about the saved login, including the generated password, are stored in a dictionary and given to your completion handler.
     Use the password extension keys above to extract the needed information and update your UI. For example, updating the UI with the
     newly generated password lets the user know their action was successful.
     */
    public func storeLogin(for loginDetails: PasswordExtensionLoginDetails, generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions?, viewController: UIViewController, sender: Any?, completion: @escaping (PasswordExtensionResponse) -> Void) {
        var item: [String: Any] = loginDetails.dictionaryRepresentation()
        if let generatedPasswordOptions = generatedPasswordOptions?.dictionaryRepresentation() {
            item[PasswordExtensionLogin.generatedPasswordOptions.key()] = generatedPasswordOptions
        }
        
        presentActivityViewController(for: item, viewController: viewController, sender: sender, typeIdentifier: PasswordExtensionActions.saveLogin.path(), completion: completion)
    }
    
    /*!
     Change the password for an existing login. The provided urlString should be
     unique to your app or service and be identical to what you pass into the find login method. The username must be the one that the user is currently logged in with.
     Details about the saved login, including the newly generated and the old password, are stored in a dictionary and given to your completion handler.
     Use the password extension keys above to extract the needed information and update your UI. For example, updating the UI with the
     newly generated password lets the user know their action was successful.
     */
    public func changePasswordForLogin(for loginDetails: PasswordExtensionLoginDetails, generatedPasswordOptions: PasswordExtensionGeneratedPasswordOptions?, viewController: UIViewController, sender: Any?, completion: @escaping (PasswordExtensionResponse) -> Void) {
        var item: [String: Any] = loginDetails.dictionaryRepresentation()
        if let generatedPasswordOptions = generatedPasswordOptions?.dictionaryRepresentation() {
            item[PasswordExtensionLogin.generatedPasswordOptions.key()] = generatedPasswordOptions
        }
        
        presentActivityViewController(for: item, viewController: viewController, sender: sender, typeIdentifier: PasswordExtensionActions.changePassword.path(), completion: completion)
    }
    
    /*!
     Called from your web view controller, this method will show all the saved logins for the active page in the provided web
     view, and automatically fill the HTML form fields. Supports both WKWebView and UIWebView.
     */
    public func fillLogin(for webView: WKWebView, viewController: UIViewController, sender: Any?, completion: @escaping (PasswordExtensionResponse) -> Void) {
        webView.evaluateJavaScript(PasswordExtension.webViewCollectFieldsScript) { [unowned self] (result, error) in
            guard let result = result as? String else {
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.failedToCollectFieldsError(with: error)))
                }
                return
            }
            
            self.findLoginForWebView(with: webView.url?.absoluteString ?? "", collectedPageDetails: result, webViewController: viewController, sender: sender, webView: webView, completion: completion)
        }
    }
}

// MARK: - Helpers

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

// MARK: - Activity View Controller

extension PasswordExtension {
    func presentActivityViewController(for item: [String: Any], viewController: UIViewController, sender: Any?, typeIdentifier: String, completion: @escaping (PasswordExtensionResponse) -> Void) {
        guard let activityVC = activityViewController(for: item, sender: sender, typeIdentifier: typeIdentifier, completion: { [unowned self] (activityType, completed, items, error) in
            self.handleActivityViewControllerCompletion(activityType: activityType, completed: completed, items: items, error: error, completion: completion)
        })
            else {
                print("Failed to find login, system API is not available")
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.systemAppExtensionAPINotAvailableError()))
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
    
    func handleActivityViewControllerCompletion(activityType: UIActivityType?, completed: Bool, items: [Any]?, error: Error?, completion: @escaping (PasswordExtensionResponse) -> Void) {
        if let error = error {
            print("Failed to contact extension: \(error)")
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToContactExtensionError(with: error)))
            }
            return
        }
        
        guard let items = items else {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToContactExtensionError(with: nil)))
            }
            return
        }
        
        if items.count == 0 {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.extensionCancelledByUserError()))
            }
            return
        }
        
        guard let firstItem = items[0] as? NSExtensionItem else {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToContactExtensionError(with: nil)))
            }
            return
        }
        self.processExtensionItem(item: firstItem, completion: completion)
    }
}

// MARK: - Process Item

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

// MARK: - Errors

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

// MARK: - Web View Integration

extension PasswordExtension {
    func findLoginForWebView(with urlString: String, collectedPageDetails: String, webViewController: UIViewController, sender: Any?, webView: WKWebView, completion: @escaping (PasswordExtensionResponse) -> Void) {
        if urlString.count == 0 {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToObtainURLStringFromWebViewError()))
            }
        }
        
        let item = [PasswordExtensionLogin.urlString.key(): urlString, PasswordExtensionWebViewPage.details.key(): collectedPageDetails]
        
        presentActivityViewController(for: item, viewController: webViewController, sender: sender, typeIdentifier: PasswordExtensionActions.fillWebView.path()) { [unowned self] (response) in
            if case let .loginSuccess(_, loginDict) = response {
                let fillScript = loginDict[PasswordExtensionWebViewPage.fillScript.key()] as? String
                self.executeFillScript(fillScript: fillScript, in: webView, completion: completion)
            } else {
                self.callOnMainThread {
                    completion(response)
                }
            }
        }
    }
    
    func executeFillScript(fillScript: String?, in webView: WKWebView, completion: @escaping (PasswordExtensionResponse) -> Void) {
        guard let fillScript = fillScript else {
            self.callOnMainThread { [unowned self] () in
                completion(.error(error: self.failedToFillFieldsError(with: "Failed to fill web page because script could not be evaluated", underlyingError: nil)))
            }
            return
        }
        
        let scriptSource = "('\(fillScript)');"
        
        webView.evaluateJavaScript(scriptSource) { (result, error) in
            guard ((result as? String) != nil) else {
                self.callOnMainThread { [unowned self] () in
                    completion(.error(error: self.failedToFillFieldsError(with: "Failed to fill web page because script could not be evaluated", underlyingError: error)))
                }
                return
            }
            
            completion(.success(success: true))
        }
    }
}

// MARK: - Web View collection and filling scripts

extension PasswordExtension {
    static let webViewCollectFieldsScript = "var f;document.collect=l;function l(a,b){var c=Array.prototype.slice.call(a.querySelectorAll('input, select'));f=b;c.forEach(p);return c.filter(function(a){q(a,['select','textarea'])?a=!0:q(a,'input')?(a=(a.getAttribute('type')||'').toLowerCase(),a=!('button'===a||'submit'===a||'reset'==a||'file'===a||'hidden'===a||'image'===a)):a=!1;return a}).map(s)}function s(a,b){var c=a.opid,d=a.id||a.getAttribute('id')||null,g=a.name||null,z=a['class']||a.getAttribute('class')||null,A=a.rel||a.getAttribute('rel')||null,B=String.prototype.toLowerCase.call(a.type||a.getAttribute('type')),C=a.value,D=-1==a.maxLength?999:a.maxLength,E=a.getAttribute('x-autocompletetype')||a.getAttribute('autocompletetype')||a.getAttribute('autocomplete')||null,k;k=[];var h,n;if(a.options){h=0;for(n=a.options.length;h<n;h++)k.push([t(a.options[h].text),a.options[h].value]);k={options:k}}else k=null;h=u(a);n=v(a);var H=w(a),I=t(a.getAttribute('data-label')),J=t(a.getAttribute('aria-label')),K=t(a.placeholder),M=x(a),m;m=[];for(var e=a;e&&e.nextSibling;){e=e.nextSibling;if(y(e))break;F(m,e)}m=t(m.join(''));e=[];G(a,e);var e=t(e.reverse().join('')),r;a.form?(a.form.opid=a.form.opid||L.a(),a.form.opdata=a.form.opdata||{htmlName:a.form.getAttribute('name'),htmlID:a.form.getAttribute('id'),htmlAction:N(a.form.getAttribute('action')),htmlMethod:a.form.getAttribute('method'),opid:a.form.opid},r=a.form.opdata):r=null;return{opid:c,elementNumber:b,htmlID:d,htmlName:g,htmlClass:z,rel:A,type:B,value:C,maxLength:D,autoCompleteType:E,selectInfo:k,visible:h,viewable:n,'label-tag':H,'label-data':I,'label-aria':J,placeholder:K,'label-top':M,'label-right':m,'label-left':e,form:r}}function p(a,b){a.opid='__'+f+'__'+b+'__'};function x(a){var b;for(a=a.parentElement||a.parentNode;a&&'td'!=(a?(a.tagName||'').toLowerCase():'');)a=a.parentElement||a.parentNode;if(!a||void 0===a)return null;b=a.parentElement||a.parentNode;if(!q(b,'tr'))return null;b=b.previousElementSibling;if(!q(b,'tr')||b.cells&&a.cellIndex>=b.cells.length)return null;a=b.cells[a.cellIndex];return t(a.innerText||a.textContent)}function w(a){var b=a.id,c=a.name,d=a.ownerDocument;if(void 0===b&&void 0===c)return null;b=O(String.prototype.replace.call(b,\"'\",\"\\\\'\"));c=O(String.prototype.replace.call(c,\"'\",\"\\\\'\"));if(b=d.querySelector(\"label[for='\"+b+\"']\")||d.querySelector(\"label[for='\"+c+\"']\"))return t(b.innerText||b.textContent);do{if('label'===(''+a.tagName).toLowerCase())return t(a.innerText||a.textContent);a=a.parentNode}while(a&&a!=d);return null};function t(a){var b=null;a&&(b=a.toLowerCase().replace(/\\s/mg,'').replace(/[~`!@$%^&*()\\-_+=:;'\"\\[\\]|\\\\,<.>\\/?]/mg,''),b=0<b.length?b:null);return b}function F(a,b){var c;c='';3===b.nodeType?c=b.nodeValue:1===b.nodeType&&(c=b.innerText||b.textContent);(c=t(c))&&a.push(c)}function y(a){return a&&void 0!==a?q(a,'select option input form textarea iframe button'.split(' ')):!0}function G(a,b,c){var d;for(c||(c=0);a&&a.previousSibling;){a=a.previousSibling;if(y(a))return;F(b,a)}if(a&&0===b.length){for(d=null;!d;){a=a.parentElement||a.parentNode;if(!a)return;for(d=a.previousSibling;d&&!y(d)&&d.lastChild;)d=d.lastChild}y(d)||(F(b,d),0===b.length&&G(d,b,c+1))}}function q(a,b){var c;if(!a)return!1;c=a?(a.tagName||'').toLowerCase():'';return b.constructor==Array?0<=b.indexOf(c):c===b}function v(a){var b,c,d,g;if(!a||!a.offsetParent)return!1;c=a.ownerDocument.documentElement;d=a.getBoundingClientRect();g=c.getBoundingClientRect();b=d.left-c.clientLeft;c=d.top-c.clientTop;if(0>b||b>g.width||0>c||c>g.height)return u(a);if(b=a.ownerDocument.elementFromPoint(b+3,c+3)){if('label'===(b.tagName||'').toLowerCase())return g=String.prototype.replace.call(a.id,\"'\",\"\\\\'\"),c=String.prototype.replace.call(a.name,\"'\",\"\\\\'\"),a=a.ownerDocument.querySelector(\"label[for='\"+g+\"']\")||a.ownerDocument.querySelector(\"label[for='\"+c+\"']\"),b===a;if(b.tagName===a.tagName)return!0}return!1}function u(a){var b=a;a=(a=a.ownerDocument)?a.defaultView:{};for(var c;b&&b!==document;){c=a.getComputedStyle?a.getComputedStyle(b,null):b.style;if('none'===c.display||'hidden'==c.visibility)return!1;b=b.parentNode}return b===document}function O(a){return a?a.replace(/([:\\\\.'])/g,'\\\\$1'):null};var P=/^[\\/\\?]/;function N(a){if(!a)return null;if(0==a.indexOf('http'))return a;var b=window.location.protocol+'//'+window.location.hostname;window.location.port&&''!=window.location.port&&(b+=':'+window.location.port);a.match(P)||(a='/'+a);return b+a}var L=new function(){return{a:function(){function a(){return(65536*(1+Math.random())|0).toString(16).substring(1).toUpperCase()}return[a(),a(),a(),a(),a(),a(),a(),a()].join('')}}}; (function collect(uuid) { var fields = document.collect(document, uuid); return { 'url': document.baseURI, 'fields': fields }; })('uuid');"
    
    static let webViewFillScript = "var e=!0,h=!0;document.fill=k;function k(a){var b,c=[],d=a.properties,f=1,g;d&&d.delay_between_operations&&(f=d.delay_between_operations);if(null!=a.savedURL&&0===a.savedURL.indexOf('https://')&&'http:'==document.location.protocol&&(b=confirm('This page is not protected. Any information you submit can potentially be seen by others. This login was originally saved on a secure page, so it is possible you are being tricked into revealing your login information.\\n\\nDo you still wish to fill this login?'),!1==b))return;g=function(a,b){var d=a[0];void 0===d?b():('delay'===d.operation?f=d.parameters[0]:c.push(l(d)),setTimeout(function(){g(a.slice(1),b)},f))};if(b=a.options)h=b.animate,e=b.markFilling;a.hasOwnProperty('script')&&(b=a.script,g(b,function(){c=Array.prototype.concat.apply(c,void 0);a.hasOwnProperty('autosubmit')&&setTimeout(function(){autosubmit(a.autosubmit,d.allow_clicky_autosubmit)},AUTOSUBMIT_DELAY);'object'==typeof protectedGlobalPage&&protectedGlobalPage.a('fillItemResults',{documentUUID:documentUUID,fillContextIdentifier:a.fillContextIdentifier,usedOpids:c},function(){})}))}var t={fill_by_opid:m,fill_by_query:n,click_on_opid:p,click_on_query:q,touch_all_fields:r,simple_set_value_by_query:s,delay:null};function l(a){var b;if(!a.hasOwnProperty('operation')||!a.hasOwnProperty('parameters'))return null;b=a.operation;return t.hasOwnProperty(b)?t[b].apply(this,a.parameters):null}function m(a,b){var c;return(c=u(a))?(v(c,b),c.opid):null}function n(a,b){var c;c=document.querySelectorAll(a);return Array.prototype.map.call(c,function(a){v(a,b);return a.opid},this)}function s(a,b){var c,d=[];c=document.querySelectorAll(a);Array.prototype.forEach.call(c,function(a){void 0!==a.value&&(a.value=b,d.push(a.opid))});return d}function p(a){a=u(a);w(a);'function'===typeof a.click&&a.click();return a?a.opid:null}function q(a){a=document.querySelectorAll(a);return Array.prototype.map.call(a,function(a){w(a);'function'===typeof a.click&&a.click();'function'===typeof a.focus&&a.focus();return a.opid},this)}function r(){x()};var y={'true':!0,y:!0,1:!0,yes:!0,'✓':!0},z=200;function v(a,b){var c;if(a&&null!==b&&void 0!==b)switch(e&&a.form&&!a.form.opfilled&&(a.form.opfilled=!0),a.type?a.type.toLowerCase():null){case 'checkbox':c=b&&1<=b.length&&y.hasOwnProperty(b.toLowerCase())&&!0===y[b.toLowerCase()];a.checked===c||A(a,function(a){a.checked=c});break;case 'radio':!0===y[b.toLowerCase()]&&a.click();break;default:a.value==b||A(a,function(a){a.value=b})}}function A(a,b){B(a);b(a);C(a);D(a)&&(a.className+=' com-agilebits-genericpassword-extension-animated-fill',setTimeout(function(){a&&a.className&&(a.className=a.className.replace(/(\\s)?com-agilebits-genericpassword-extension-animated-fill/,''))},z))};function E(a,b){var c;c=a.ownerDocument.createEvent('KeyboardEvent');c.initKeyboardEvent?c.initKeyboardEvent(b,!0,!0):c.initKeyEvent&&c.initKeyEvent(b,!0,!0,null,!1,!1,!1,!1,0,0);a.dispatchEvent(c)}function B(a){w(a);a.focus();E(a,'keydown');E(a,'keyup');E(a,'keypress')}function C(a){var b=a.ownerDocument.createEvent('HTMLEvents'),c=a.ownerDocument.createEvent('HTMLEvents');E(a,'keydown');E(a,'keyup');E(a,'keypress');c.initEvent('input',!0,!0);a.dispatchEvent(c);b.initEvent('change',!0,!0);a.dispatchEvent(b);a.blur()}function w(a){!a||a&&'function'!==typeof a.click||a.click()}function F(){var a=RegExp('(pin|password|passwort|kennwort|passe|contraseña|senha|密码|adgangskode|hasło|wachtwoord)','i');return Array.prototype.slice.call(document.querySelectorAll(\"input[type='text']\")).filter(function(b){return b.value&&a.test(b.value)},this)}function x(){F().forEach(function(a){B(a);a.click&&a.click();C(a)})}function D(a){var b;if(b=h)a:{b=a;for(var c=a.ownerDocument,c=c?c.defaultView:{},d;b&&b!==document;){d=c.getComputedStyle?c.getComputedStyle(b,null):b.style;if('none'===d.display||'hidden'==d.visibility){b=!1;break a}b=b.parentNode}b=b===document}return b?-1!=='email text password number tel url'.split(' ').indexOf(a.type||''):!1}function u(a){var b,c,d;if(a)for(d=document.querySelectorAll('input, select'),b=0,c=d.length;b<c;b++)if(d[b].opid==a)return d[b];return null}; (function execute_fill_script(scriptJSON) { var script = null, error = null; try { script = JSON.parse(scriptJSON);} catch (e) { error = e; } if (!script) { return { 'success': false, 'error': 'Unable to parse fill script JSON. Javascript exception: ' + error }; } document.fill(script); return {'success': true}; })"
    
}
