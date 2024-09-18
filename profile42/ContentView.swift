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

struct ContentView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession
    @ObservedObject private var api = API()
    @State private var selectedTab: TabProfile = .projects
    private var authManager = AuthManager()
    @State private var showingWebView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !api.isLoading {
                ScrollView {
                    AsyncImage(url: URL(string: api.user.image.link)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
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
                                    Text("\(api.currentCursus.grade ?? "N/A")")
                                }
                                .padding(.vertical)
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 60)
                            .background(.gray)
                            .clipShape(Rectangle())
                            .padding()
                            // TODO add weekly attendance
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
                    VStack(alignment: .center) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "envelope")
                                Text(api.user.email)
                                    .foregroundStyle(.blue)
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(api.user.campus.first?.name ?? "Unknown Campus")
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.gray)
                    LocationView(api: api)
                    HStack {
                        VStack {
                            ForEach(TabProfile.allCases, id: \.self) { tab in
                                Image(systemName: tab.image)
                                    .padding(5)
                                    .background(tab == selectedTab ? Color.gray.opacity(0.2) : .clear)
                                    .onTapGesture {
                                        selectedTab = tab
                                        print("Selected tab: \(tab)")
                                    }
                                    .padding(.vertical, 5)
                            }
                        }
                        VStack {
                            switch selectedTab {
                            case .projects:
                                ProjectView(api: api)
                            case .achievements:
                                AchievementsView(api: api)
                            case .patronage:
                                ScrollView {}
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    HStack {
                        CurrentProjectView(api: api)
                        Spacer()
                    }
                    SkillsView(api: api)
                }
                .foregroundStyle(.white)
            } else {
                Button("Login with OAuth 2.0") {
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
        .onChange(of: api.accessToken) {
            if !api.accessToken.isEmpty {
                Task {
                    do {
                        api.isLoading = true
                        let user: User = try await api.fetchData(API.UserEndPoint.user)
                        api.user = user
                        api.coalitions = try await api.fetchData(API.UserEndPoint.coalition(id: user.id))
                        api.currentCoalition = api.coalitions.first!
                        api.currentCursus = api.getCurrentCursus()
                        api.finishedProjects = api.getFinihedProjects()
                        api.currentProjects = api.getCurrentProjects()
                        api.locationStats = try await api.fetchData(API.LocationEndPoint.location(id: user.id, startDate: api.currentCursus.beginAt))
                        print(api.locationStats.count)
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
