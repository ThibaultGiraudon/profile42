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
                    Text(api.user.login)
                        .font(.title2.bold())
                        .foregroundStyle(.gray)
                        .padding()
                        .contextMenu {
                            Button("View my profile") {
                                api.selectedUser = api.user
                                api.activeTab = .otherProfile
                            }
                            .disabled(api.isLoading)
                            Button("Logout", role: .destructive) {
                                api.logOut()
                            }
                            .disabled(api.isLoading)
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
                                let applicationToken: ApplicationToken = try await api.getToken(endpoint: API.AuthEndPoint.application)
                                api.applicationToken = applicationToken.accessToken
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
            if api.coalitions.isEmpty {
                api.isLoading = true
                Task {
                    do {
                        let user: User = try await api.fetchData(API.UserEndPoint.user)
                        api.user = user
                        api.currentCursus = api.getCurrentCursus(from: user.cursusUsers)
                        api.currentCampus = api.getCurrentCampus(from: user.campus)
                        api.events = try await api.fetchData(API.EventEndPoints.events(campusID: api.currentCampus.id, cursusID: api.currentCursus.cursusID))
                        api.coalitions = try await api.fetchData(API.CoalitionEndPoint.coalition(id: user.id))
                        api.isLoggedIn = true
                    } catch {
                        print(error)
                        api.alertTitle = error.localizedDescription
                        api.showAlert = true
                        api.activeTab = .profile
                    }
                }
                api.isLoading = false
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
