//
//  IFrameViewController.swift
//  TestPanda
//
//  Created by Toseef on 4/27/21.
//

import Foundation
import UIKit
import WebKit

class IFrameViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var url: URL!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        // Inject JavaScript which sending message to App
        let scrpt = """
        var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent',
              messageEvent = eventMethod === 'attachEvent' ? 'onmessage' : 'message';

            window[eventMethod](messageEvent,function(e) {
            if (e && e.data) {
              try {
                var message = JSON.parse(e.data);
                if (message && message.event) {
            window.webkit.messageHandlers.callbackHandler.postMessage(message.event);

            }
              } catch(e) {
              console.log(e);
              }
            }
          }, false);
        """
        let userScript = WKUserScript(source: scrpt, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        contentController.removeAllUserScripts()
        contentController.addUserScript(userScript)
        // Add ScriptMessageHandler
        contentController.add(
            self,
            name: "callbackHandler"
        )

        webConfiguration.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPageLoad()
    }
    /// This method is used to start page load
    /// - Author: Toseef
    func startPageLoad() {
        // Create a URL request and load it in the web view.
        let request = URLRequest(url: url)
        webView.load(request)
    }

    // Implement `WKScriptMessageHandler`，handle message which been sent by JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.name)")

            if let event = message.body as? String , event == "session_view.document.completed" {
                self.showAlert("Success", message: "Congratulations!!!\n You have successfully completed the document.", alertButtonTitles: "Ok") {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            print("didRecieve message:\(message)")
        }
    }
}
// MARK: - WK Navigation Delegate method
extension IFrameViewController: WKNavigationDelegate {
    /// WKWebView WKNavigation Delegate method
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let absoluteURL = navigationAction.request.url?.absoluteString ?? ""
        print("URL:\(absoluteURL)")
        decisionHandler(.allow)
    }

    /// WKWebView WKNavigation Delegate method
    func webView(_ webView: WKWebView, didStart navigation: WKNavigation!) {
    }

    /// WKWebView WKNavigation Delegate method
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    /// WKWebView WKNavigation Delegate method
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Page error:\(error)")
    }
}

extension UIViewController {

    func showAlert(_ title: String? = nil, message: String? = nil, alertButtonTitles: String,  completion: @escaping () -> Void) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)

        let style: UIAlertAction.Style = .default
            let action = UIAlertAction(title: alertButtonTitles, style: style) { _ in
                completion()
            }
            alert.addAction(action)

        self.present(alert, animated: true) {
        }
    }
}
