//
//  PasswordExtension+WebViewIntegration.swift
//  PasswordExtension
//
//  Created by Niklas Fahl on 10/20/17.
//

import Foundation
import WebKit

extension PasswordExtension {
    func findLoginForWebView(with urlString: String, collectedPageDetails: String, webViewController: UIViewController, sender: Any?, webView: WKWebView, completion: @escaping (_ success: Bool, _ error: PEError?) -> Void) {
        if urlString.count == 0 {
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToObtainURLStringFromWebViewError()
                completion(false, error)
            }
        }
        
        let item = [PELogin.urlString.key(): urlString, PEWebViewPage.details.key(): collectedPageDetails]
        
        presentActivityViewController(for: item, viewController: webViewController, sender: sender, typeIdentifier: PEActions.fillWebView.path()) { [unowned self] (response, error) in
            if let error = error {
                self.callOnMainThread {
                    completion(false, error)
                }
            } else if let response = response {
                let fillScript = response.loginDict[PEWebViewPage.fillScript.key()] as? String
                self.executeFillScript(fillScript: fillScript, in: webView, completion: completion)
            }
        }
    }
    
    func executeFillScript(fillScript: String?, in webView: WKWebView, completion: @escaping (_ success: Bool, _ error: PEError?) -> Void) {
        guard let fillScript = fillScript else {
            self.callOnMainThread { [unowned self] () in
                let error = self.failedToFillFieldsError(with: "Failed to fill web page because script could not be evaluated", underlyingError: nil)
                completion(false, error)
            }
            return
        }
        
        let scriptSource = "\(PasswordExtension.webViewFillScript)('\(fillScript)');"
        
        webView.evaluateJavaScript(scriptSource) { (result, error) in
            guard ((result as? String) != nil) else {
                self.callOnMainThread { [unowned self] () in
                    let error = self.failedToFillFieldsError(with: "Failed to fill web page because script could not be evaluated", underlyingError: error)
                    completion(false, error)
                }
                return
            }
            
            completion(true, nil)
        }
    }
}

// MARK: - Web View collection and filling scripts

extension PasswordExtension {
    static let webViewCollectFieldsScript = "var f;document.collect=l;function l(a,b){var c=Array.prototype.slice.call(a.querySelectorAll('input, select'));f=b;c.forEach(p);return c.filter(function(a){q(a,['select','textarea'])?a=!0:q(a,'input')?(a=(a.getAttribute('type')||'').toLowerCase(),a=!('button'===a||'submit'===a||'reset'==a||'file'===a||'hidden'===a||'image'===a)):a=!1;return a}).map(s)}function s(a,b){var c=a.opid,d=a.id||a.getAttribute('id')||null,g=a.name||null,z=a['class']||a.getAttribute('class')||null,A=a.rel||a.getAttribute('rel')||null,B=String.prototype.toLowerCase.call(a.type||a.getAttribute('type')),C=a.value,D=-1==a.maxLength?999:a.maxLength,E=a.getAttribute('x-autocompletetype')||a.getAttribute('autocompletetype')||a.getAttribute('autocomplete')||null,k;k=[];var h,n;if(a.options){h=0;for(n=a.options.length;h<n;h++)k.push([t(a.options[h].text),a.options[h].value]);k={options:k}}else k=null;h=u(a);n=v(a);var H=w(a),I=t(a.getAttribute('data-label')),J=t(a.getAttribute('aria-label')),K=t(a.placeholder),M=x(a),m;m=[];for(var e=a;e&&e.nextSibling;){e=e.nextSibling;if(y(e))break;F(m,e)}m=t(m.join(''));e=[];G(a,e);var e=t(e.reverse().join('')),r;a.form?(a.form.opid=a.form.opid||L.a(),a.form.opdata=a.form.opdata||{htmlName:a.form.getAttribute('name'),htmlID:a.form.getAttribute('id'),htmlAction:N(a.form.getAttribute('action')),htmlMethod:a.form.getAttribute('method'),opid:a.form.opid},r=a.form.opdata):r=null;return{opid:c,elementNumber:b,htmlID:d,htmlName:g,htmlClass:z,rel:A,type:B,value:C,maxLength:D,autoCompleteType:E,selectInfo:k,visible:h,viewable:n,'label-tag':H,'label-data':I,'label-aria':J,placeholder:K,'label-top':M,'label-right':m,'label-left':e,form:r}}function p(a,b){a.opid='__'+f+'__'+b+'__'};function x(a){var b;for(a=a.parentElement||a.parentNode;a&&'td'!=(a?(a.tagName||'').toLowerCase():'');)a=a.parentElement||a.parentNode;if(!a||void 0===a)return null;b=a.parentElement||a.parentNode;if(!q(b,'tr'))return null;b=b.previousElementSibling;if(!q(b,'tr')||b.cells&&a.cellIndex>=b.cells.length)return null;a=b.cells[a.cellIndex];return t(a.innerText||a.textContent)}function w(a){var b=a.id,c=a.name,d=a.ownerDocument;if(void 0===b&&void 0===c)return null;b=O(String.prototype.replace.call(b,\"'\",\"\\\\'\"));c=O(String.prototype.replace.call(c,\"'\",\"\\\\'\"));if(b=d.querySelector(\"label[for='\"+b+\"']\")||d.querySelector(\"label[for='\"+c+\"']\"))return t(b.innerText||b.textContent);do{if('label'===(''+a.tagName).toLowerCase())return t(a.innerText||a.textContent);a=a.parentNode}while(a&&a!=d);return null};function t(a){var b=null;a&&(b=a.toLowerCase().replace(/\\s/mg,'').replace(/[~`!@$%^&*()\\-_+=:;'\"\\[\\]|\\\\,<.>\\/?]/mg,''),b=0<b.length?b:null);return b}function F(a,b){var c;c='';3===b.nodeType?c=b.nodeValue:1===b.nodeType&&(c=b.innerText||b.textContent);(c=t(c))&&a.push(c)}function y(a){return a&&void 0!==a?q(a,'select option input form textarea iframe button'.split(' ')):!0}function G(a,b,c){var d;for(c||(c=0);a&&a.previousSibling;){a=a.previousSibling;if(y(a))return;F(b,a)}if(a&&0===b.length){for(d=null;!d;){a=a.parentElement||a.parentNode;if(!a)return;for(d=a.previousSibling;d&&!y(d)&&d.lastChild;)d=d.lastChild}y(d)||(F(b,d),0===b.length&&G(d,b,c+1))}}function q(a,b){var c;if(!a)return!1;c=a?(a.tagName||'').toLowerCase():'';return b.constructor==Array?0<=b.indexOf(c):c===b}function v(a){var b,c,d,g;if(!a||!a.offsetParent)return!1;c=a.ownerDocument.documentElement;d=a.getBoundingClientRect();g=c.getBoundingClientRect();b=d.left-c.clientLeft;c=d.top-c.clientTop;if(0>b||b>g.width||0>c||c>g.height)return u(a);if(b=a.ownerDocument.elementFromPoint(b+3,c+3)){if('label'===(b.tagName||'').toLowerCase())return g=String.prototype.replace.call(a.id,\"'\",\"\\\\'\"),c=String.prototype.replace.call(a.name,\"'\",\"\\\\'\"),a=a.ownerDocument.querySelector(\"label[for='\"+g+\"']\")||a.ownerDocument.querySelector(\"label[for='\"+c+\"']\"),b===a;if(b.tagName===a.tagName)return!0}return!1}function u(a){var b=a;a=(a=a.ownerDocument)?a.defaultView:{};for(var c;b&&b!==document;){c=a.getComputedStyle?a.getComputedStyle(b,null):b.style;if('none'===c.display||'hidden'==c.visibility)return!1;b=b.parentNode}return b===document}function O(a){return a?a.replace(/([:\\\\.'])/g,'\\\\$1'):null};var P=/^[\\/\\?]/;function N(a){if(!a)return null;if(0==a.indexOf('http'))return a;var b=window.location.protocol+'//'+window.location.hostname;window.location.port&&''!=window.location.port&&(b+=':'+window.location.port);a.match(P)||(a='/'+a);return b+a}var L=new function(){return{a:function(){function a(){return(65536*(1+Math.random())|0).toString(16).substring(1).toUpperCase()}return[a(),a(),a(),a(),a(),a(),a(),a()].join('')}}}; (function collect(uuid) { var fields = document.collect(document, uuid); return { 'url': document.baseURI, 'fields': fields }; })('uuid');"
    
    static let webViewFillScript = "var e=!0,h=!0;document.fill=k;function k(a){var b,c=[],d=a.properties,f=1,g;d&&d.delay_between_operations&&(f=d.delay_between_operations);if(null!=a.savedURL&&0===a.savedURL.indexOf('https://')&&'http:'==document.location.protocol&&(b=confirm('This page is not protected. Any information you submit can potentially be seen by others. This login was originally saved on a secure page, so it is possible you are being tricked into revealing your login information.\\n\\nDo you still wish to fill this login?'),!1==b))return;g=function(a,b){var d=a[0];void 0===d?b():('delay'===d.operation?f=d.parameters[0]:c.push(l(d)),setTimeout(function(){g(a.slice(1),b)},f))};if(b=a.options)h=b.animate,e=b.markFilling;a.hasOwnProperty('script')&&(b=a.script,g(b,function(){c=Array.prototype.concat.apply(c,void 0);a.hasOwnProperty('autosubmit')&&setTimeout(function(){autosubmit(a.autosubmit,d.allow_clicky_autosubmit)},AUTOSUBMIT_DELAY);'object'==typeof protectedGlobalPage&&protectedGlobalPage.a('fillItemResults',{documentUUID:documentUUID,fillContextIdentifier:a.fillContextIdentifier,usedOpids:c},function(){})}))}var t={fill_by_opid:m,fill_by_query:n,click_on_opid:p,click_on_query:q,touch_all_fields:r,simple_set_value_by_query:s,delay:null};function l(a){var b;if(!a.hasOwnProperty('operation')||!a.hasOwnProperty('parameters'))return null;b=a.operation;return t.hasOwnProperty(b)?t[b].apply(this,a.parameters):null}function m(a,b){var c;return(c=u(a))?(v(c,b),c.opid):null}function n(a,b){var c;c=document.querySelectorAll(a);return Array.prototype.map.call(c,function(a){v(a,b);return a.opid},this)}function s(a,b){var c,d=[];c=document.querySelectorAll(a);Array.prototype.forEach.call(c,function(a){void 0!==a.value&&(a.value=b,d.push(a.opid))});return d}function p(a){a=u(a);w(a);'function'===typeof a.click&&a.click();return a?a.opid:null}function q(a){a=document.querySelectorAll(a);return Array.prototype.map.call(a,function(a){w(a);'function'===typeof a.click&&a.click();'function'===typeof a.focus&&a.focus();return a.opid},this)}function r(){x()};var y={'true':!0,y:!0,1:!0,yes:!0,'✓':!0},z=200;function v(a,b){var c;if(a&&null!==b&&void 0!==b)switch(e&&a.form&&!a.form.opfilled&&(a.form.opfilled=!0),a.type?a.type.toLowerCase():null){case 'checkbox':c=b&&1<=b.length&&y.hasOwnProperty(b.toLowerCase())&&!0===y[b.toLowerCase()];a.checked===c||A(a,function(a){a.checked=c});break;case 'radio':!0===y[b.toLowerCase()]&&a.click();break;default:a.value==b||A(a,function(a){a.value=b})}}function A(a,b){B(a);b(a);C(a);D(a)&&(a.className+=' com-agilebits-password-extension-animated-fill',setTimeout(function(){a&&a.className&&(a.className=a.className.replace(/(\\s)?com-agilebits-password-extension-animated-fill/,''))},z))};function E(a,b){var c;c=a.ownerDocument.createEvent('KeyboardEvent');c.initKeyboardEvent?c.initKeyboardEvent(b,!0,!0):c.initKeyEvent&&c.initKeyEvent(b,!0,!0,null,!1,!1,!1,!1,0,0);a.dispatchEvent(c)}function B(a){w(a);a.focus();E(a,'keydown');E(a,'keyup');E(a,'keypress')}function C(a){var b=a.ownerDocument.createEvent('HTMLEvents'),c=a.ownerDocument.createEvent('HTMLEvents');E(a,'keydown');E(a,'keyup');E(a,'keypress');c.initEvent('input',!0,!0);a.dispatchEvent(c);b.initEvent('change',!0,!0);a.dispatchEvent(b);a.blur()}function w(a){!a||a&&'function'!==typeof a.click||a.click()}function F(){var a=RegExp('(pin|password|passwort|kennwort|passe|contraseña|senha|密码|adgangskode|hasło|wachtwoord)','i');return Array.prototype.slice.call(document.querySelectorAll(\"input[type='text']\")).filter(function(b){return b.value&&a.test(b.value)},this)}function x(){F().forEach(function(a){B(a);a.click&&a.click();C(a)})}function D(a){var b;if(b=h)a:{b=a;for(var c=a.ownerDocument,c=c?c.defaultView:{},d;b&&b!==document;){d=c.getComputedStyle?c.getComputedStyle(b,null):b.style;if('none'===d.display||'hidden'==d.visibility){b=!1;break a}b=b.parentNode}b=b===document}return b?-1!=='email text password number tel url'.split(' ').indexOf(a.type||''):!1}function u(a){var b,c,d;if(a)for(d=document.querySelectorAll('input, select'),b=0,c=d.length;b<c;b++)if(d[b].opid==a)return d[b];return null}; (function execute_fill_script(scriptJSON) { var script = null, error = null; try { script = JSON.parse(scriptJSON);} catch (e) { error = e; } if (!script) { return { 'success': false, 'error': 'Unable to parse fill script JSON. Javascript exception: ' + error }; } document.fill(script); return {'success': true}; })"
}
