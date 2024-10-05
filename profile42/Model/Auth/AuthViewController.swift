//
//  AuthViewController.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
@preconcurrency import WebKit

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

        // Effacer les cookies et les données avant de charger l'URL
        clearCookiesAndCache {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // Fonction pour effacer les cookies et les données de cache
    func clearCookiesAndCache(completion: @escaping () -> Void) {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        
        dataStore.fetchDataRecords(ofTypes: types) { records in
            dataStore.removeData(ofTypes: types, for: records) {
                print("Cookies and cache cleared")
                completion()
            }
        }
    }
}

