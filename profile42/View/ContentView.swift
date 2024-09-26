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
    case project
}

struct ContentView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @ObservedObject private var api = API()
    @State private var selectedTab: TabProfile = .projects
    @State private var showingWebView = false
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if api.isLoggedIn {
                HStack {
                    ZStack {
                        Color.gray
                        Image("42")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(10)
                            .onTapGesture {
                                api.activeTab = .profile
                                api.navHistory.append(.profile)
                                print(api.navHistory)
                                print(api.navHistory.count)
                            }
                    }
                    .frame(width: 100, height: 70)
                    Button {
                        api.activeTab = .search
                        api.navHistory.append(.search)
                        print(api.navHistory)
                        print(api.navHistory.count)
                    } label: {
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
                ZStack {
//                    if api.navHistory.count > 1 {
//                        
//                        switch api.navHistory[api.navHistory.count - 2] {
//                        case .search:
//                            SearchView(api: api)
//                        case .profile:
//                            ProfileView(api: api, events: api.events)
//                        case .otherProfile:
//                            OtherProfileView(api: api, user: api.selectedUser)
//                        case .project:
//                            ProjectDetailView(api: api)
//                        }
//                    }
                    
                    ZStack {
                        switch api.activeTab {
                        case .search:
                            SearchView(api: api)
                        case .profile:
                            ProfileView(api: api, events: api.events)
                        case .otherProfile:
                            OtherProfileView(api: api, user: api.selectedUser)
                        case .project:
                            ProjectDetailView(api: api)
                        }
                    }
                    .background(.white)
//                        .gesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    if api.navHistory.count > 1 && value.translation.width > 0 {
//                                        offset = value.translation.width
//                                    }
//                                }
//                                .onEnded { value in
//                                    if api.navHistory.count > 1 && value.translation.width > 100 {
//                                        goBack()
//                                    }
//                                    offset = 0
//                                }
//                        )
//                        .offset(x: offset)
                }
            } else {
                Button("Login with OAuth 2.0") {
                    showingWebView = true
                }
                .sheet(isPresented: $showingWebView) {
                    AuthViewController(url: API.Constants.authURL) { code in
                        Task {
                            do {
                                let token: Token = try await api.getToken(endpoint: API.AuthEndPoint.user(code: code))
                                api.token = token
                                let applicationToken: ApplicationToken = try await api.getToken(endpoint: API.AuthEndPoint.application)
                                api.applicationToken = applicationToken.accessToken
                                api.isLoggedIn = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
        .alert(isPresented: $api.showAlert) {
            Alert(title: Text(api.alertTitle))
        }
    }
    private func goBack() {
        guard !api.navHistory.isEmpty else { return }
        api.navHistory.removeLast()
        if let lastTab = api.navHistory.last {
            api.activeTab = lastTab
        } else {
            api.activeTab = .profile
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
