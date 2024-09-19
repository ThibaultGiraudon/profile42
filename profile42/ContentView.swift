//
//  ContentView.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import SwiftUI
import AuthenticationServices
import WebKit
import Charts

enum TabProfile: CaseIterable {
    case projects
    case achievements
    case patronage
    
    var image: String {
        switch self {
        case .projects:
            "folder"
        case .achievements:
            "medal"
        case .patronage:
            "person.badge.shield.checkmark"
        }
    }
}

enum Tab {
    case profile
    case search
    case otherProfile
}

struct ContentView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @ObservedObject private var api = API()
    @State private var selectedTab: TabProfile = .projects
    private var authManager = AuthManager()
    @State private var showingWebView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !api.isLoading {
                HStack {
                    ZStack {
                        Color.gray
                        Image("42")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(10)
                            .onTapGesture {
                                api.activeTab = .profile
                            }
                    }
                    .frame(width: 100, height: 70)
                    Button(action: { api.activeTab = .search}) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.cyan)
                            .padding()
                    }
                    Spacer()
                    Text(api.user.login)
                        .font(.title2.bold())
                        .foregroundStyle(.gray)
                        .padding()
                }
                switch api.activeTab {
                case .search:
                    SearchView(api: api)
                case .profile:
                    ProfileView(api: api, events: api.events)
                case .otherProfile:
                    OtherProfileView(api: api, user: api.selectedUser)
                }
            } else {
                Button("Login with OAuth 2.0") {
//                    let user: User = decode("user.json")
//                    api.user = user
//                    api.coalitions = decode("coalitions.json")
//                    api.currentCoalition = api.coalitions.first!
//                    api.currentCursus = api.getCurrentCursus()
//                    api.finishedProjects = api.getFinihedProjects()
//                    api.currentProjects = api.getCurrentProjects()
//                    api.locationStats = decode("locationsStats.json")
//                    print(api.locationStats.count)
//                    api.isLoading = false
                    showingWebView = true
//                    Task {
//                        do {
//                            let callbackURLScheme = API.Constants.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//                            
//                            guard let authURL = API.AuthEndPoint.authorize.url, let callBackURL = callbackURLScheme else { return }
//                            
//                            print("Auth URL: \(authURL)")
//                            print("Callback URL: \(callBackURL)")
//                            
//                            let url = try await webAuthenticationSession.authenticate(using: authURL, callbackURLScheme: callBackURL)
//                            
//                            let queryItems = URLComponents(string: url.absoluteString)?.queryItems
//                            guard let code = queryItems?.first(where: { $0.name == "code" })?.value else { return }
//                            
//                            print("Code: \(code)")
//                            
//                            let userToken = try await api.exchangeCodeForToken(endpoint: API.AuthEndPoint.user(code: code))
//                            let applicationToken = try await api.exchangeCodeForToken(endpoint: API.AuthEndPoint.application)
//                            
//                            api.accessToken = userToken
//                            api.applicationToken = applicationToken
//                            print("User token: \(userToken)")
//                            print("Application token: \(applicationToken)")
//                        } catch {
//                            print("Auth error")
//                            print(error)
//                        }
//                    }
                }
                .sheet(isPresented: $showingWebView) {
                    AuthViewController(url: authManager.authURL) { code in
                        Task {
                            do {
                                let userToken = try await api.exchangeCodeForToken(endpoint: API.AuthEndPoint.user(code: code))
                                api.accessToken = userToken
                                let applicationToken = try await api.exchangeCodeForToken(endpoint: API.AuthEndPoint.application)
                                api.applicationToken = applicationToken
                            } catch {
                                print("Auth error")
                                print(error)
                            }
                        }
                        
                    }
                }
            }
        }
//        .onAppear {
//            let user: User = decode("user.json")
//            api.user = user
//            api.coalitions = decode("coalitions.json")
//            api.locationStats = decode("locationsStats.json")
//            api.currentCoalition = api.coalitions.first!
//            api.currentCursus = api.getCurrentCursus()
//            api.finishedProjects = api.getFinihedProjects()
//            api.currentProjects = api.getCurrentProjects()
//            print(api.locationStats.count)
//            api.isLoading = false
//        }
        .onChange(of: api.accessToken) {
            if !api.accessToken.isEmpty {
                Task {
                    do {
                        api.isLoading = true
                        let user: User = try await api.fetchData(API.UserEndPoint.user)
                        api.user = user
                        api.events = try await api.fetchData(API.EventEndPoints.events(campusID: 9, cursusID: 21))
//                        api.coalitions = try await api.fetchData(API.UserEndPoint.coalition(id: user.id))
//                        api.currentCoalition = api.coalitions.first!
//                        api.currentCursus = api.getCurrentCursus()
//                        api.finishedProjects = api.getFinihedProjects()
//                        api.currentProjects = api.getCurrentProjects()
//                        api.locationStats = try await api.fetchData(API.LocationEndPoint.location(id: user.id, startDate: api.currentCursus.beginAt))
                        api.isLoading = false
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
