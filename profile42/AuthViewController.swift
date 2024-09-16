//
//  AuthViewController.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
import WebKit

struct AuthViewController: UIViewRepresentable {
    let url: URL
    let onCodeReceived: (String) -> Void
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: AuthViewController

        init(parent: AuthViewController) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, url.absoluteString.starts(with: "https://www.google.com/") {
                if let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value {
                    parent.onCodeReceived(code)
                }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
