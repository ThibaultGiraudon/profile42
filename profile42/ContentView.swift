//
//  ContentView.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
import WebKit

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
