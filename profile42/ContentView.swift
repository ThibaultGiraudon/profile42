//
//  ContentView.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
import WebKit

struct Constants {
    static let authorizationApiUrl = "https://api.intra.42.fr/oauth/authorize"
    static let clientID = "u-s4t2ud-1ed84540bd1267e075ee676f586b51a1d2c311c5e29f82473e31c50cef31b732"
    static let clientSecret = "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"
    static let tokenAPIURL  = "https://api.intra.42.fr/oauth/token"
    static let redirectURI = "https://www.google.com/"
    static let scopes = "public+projects+profile"
}

struct ContentView: View {
    private var authManager = AuthManager()
    @State private var showingWebView = false
    @State private var accessToken: String?

    var body: some View {
        VStack {
            if let token = accessToken {
                Text("Access Token: \(token)")
            } else {
                Button("Login with OAuth 2.0") {
                    showingWebView = true
                }
                .sheet(isPresented: $showingWebView) {
                    AuthViewController(url: authManager.authURL) { code in
                        // Échanger le code d'autorisation contre un token
                        authManager.exchangeCodeForToken(code: code) { token in
                            accessToken = token
                        }
                        showingWebView = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
