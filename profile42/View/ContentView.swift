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
    case event
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
                        Color("CustomBlack")
                        Image("42")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(10)
                            .onTapGesture {
                                if !api.isLoading {
                                    api.activeTab = .profile
                                    api.navHistory.append(.profile)
                                }
                            }
                    }
                    .frame(width: 100, height: 70)
                    Button {
                        api.activeTab = .search
                        api.navHistory.append(.search)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.cyan)
                            .padding()
                    }
                    .disabled(api.isLoading)
                    Spacer()
                    Menu {
                        Button("View my profile") {
                            api.selectedUser = api.user
                            api.navHistory.append(.otherProfile)
                            api.userHistory.append(api.user)
                            print(api.userHistory.count)
                            api.activeTab = .otherProfile
                        }
                        .disabled(api.isLoading)
                        Button("Setting") {
                            api.activeTab = .profile
                            
                        }
                        Button("Logout", role: .destructive) {
                            api.logOut()
                        }
                        .disabled(api.isLoading)
                    } label: {
                        Text(api.user.login)
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                            .padding()
                    }
                }
                ZStack {
                    ZStack {
                        switch api.activeTab {
                        case .search:
                            SearchView(api: api)
                        case .profile:
                            ProfileView(api: api, user: api.user)
                        case .otherProfile:
                            ProfileView(api: api, user: api.selectedUser)
                        case .project:
                            ProjectDetailView(api: api)
                        case .event:
                            EventDetailView(api: api, event: api.selectedEvent)
                        }
                    }
                    .background(.white)
                    .offset(x: offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if api.navHistory.count > 1 && value.translation.width > 0 {
                                        offset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if api.navHistory.count > 1 && value.translation.width > 100 {
                                        goBack()
                                    }
                                    offset = 0
                                }
                        )
                }
                .overlay {
                    if api.isLoading {
                        GeometryReader { geometry in
                            ProgressView()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .ignoresSafeArea(.all)
                                .background(.white)
                        }
                    }
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
                                print(token.accessToken)
                                let applicationToken: ApplicationToken = try await api.getToken(endpoint: API.AuthEndPoint.application)
                                api.applicationToken = applicationToken.accessToken
                                print(applicationToken.accessToken)
                                showingWebView = false
                            } catch {
                                api.alertTitle = error.localizedDescription
                                api.showAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: api.applicationToken) {
            Task {
                do {
                    try await api.logIn()
                } catch {
                    print(error)
                    api.alertTitle = error.localizedDescription
                    api.showAlert = true
                    api.activeTab = .profile
                }
            }
        }
        .onAppear {
            if !api.isLoggedIn {
                Task {
                    do {
                        try await api.logIn()
                    } catch {
                        print(error)
                        api.alertTitle = error.localizedDescription
                        api.showAlert = true
                        api.activeTab = .profile
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
            if api.activeTab == .otherProfile {
                if api.userHistory.count > 0 {
                    api.userHistory.removeLast()
                }
            }
            if lastTab == .otherProfile {
                api.selectedUser = api.userHistory.last ?? api.user
                if api.userHistory.count > 0 {
                    api.userHistory.removeLast()
                }
            }
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
