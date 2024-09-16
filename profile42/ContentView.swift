//
//  ContentView.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject private var api = API()
    private var authManager = AuthManager()
    @State private var showingWebView = false
    @State private var accessToken: String?

    var body: some View {
        VStack {
            if !api.isLoading {
                ScrollView {
                    ZStack {
                        AsyncImage(url: URL(string: api.currentCoalition.coverURL)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        VStack {
                            VStack(alignment: .center) {
                                Image(systemName: api.currentCoalition.imageURL)
                                Text(api.currentCoalition.name)
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text("\(api.currentCoalition.score)")
                                    Image(systemName: "baseball.diamond.bases")
                                    Text("0")
                                }
                                Text(api.user.usualFullName)
                                    .font(.title2.bold())
                                Text(api.user.login)
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Wallet")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(api.user.wallet)₳")
                                }
                                .padding(.vertical)
                                HStack {
                                    Text("Evaluation points")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(api.user.correctionPoint)")
                                }
                                .padding(.vertical)
                                // TODO change this with a picker
                                HStack {
                                    Text("Cursus")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("42 Cursus")
                                }
                                .padding(.vertical)
                                HStack {
                                    Text("Grade")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(api.user.kind)")
                                }
                                .padding(.vertical)
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 60)
                            .background(.gray)
                            .clipShape(Rectangle())
                            .padding()
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 20)
                                    .foregroundStyle(.ultraThinMaterial)
                                Rectangle()
                                    .frame(width: (UIScreen.main.bounds.width - 20) * api.currentCursus.level.truncatingRemainder(dividingBy: 1), height: 20)
                                    .foregroundStyle(.blue)
                                HStack {
                                    Spacer()
                                    Text("level \(api.currentCursus.level, specifier: "%.0f") - \(api.currentCursus.level.truncatingRemainder(dividingBy: 1) * 100,  specifier: "%.0f")%")
                                    Spacer()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding()
                        }
                        .padding(.top)
                    }
                }
                .foregroundStyle(.white)
            } else {
                Button("Login with OAuth 2.0") {
                    showingWebView = true
                }
                .sheet(isPresented: $showingWebView) {
                    AuthViewController(url: authManager.authURL) { code in
                        // Échanger le code d'autorisation contre un token
                        authManager.exchangeCodeForToken(code: code) { token in
                            api.token = token
                        }
                        showingWebView = false
                    }
                }
            }
        }
        .onChange(of: api.token) {
            if !api.token.isEmpty {
                Task {
                    do {
                        api.isLoading = true
                        let user: User = try await api.fetchData(APIPath.authenticate)
                        api.user = user
                        api.coalitions = try await api.fetchData(APIPath.coalition(id: user.id))
                        api.currentCoalition = api.coalitions.first!
                        api.currentCursus = api.getCurrentCursus()
                        api.isLoading = false
                    } catch {
                        print(error)
                        api.isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
