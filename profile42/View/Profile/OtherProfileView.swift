//
//  ProfileView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var api: API
    @State private var selectedTab: TabProfile = .projects
    @State var user: User
    private var selectedCursus: CursusUser {
        var latestCursus = user.cursusUsers.first ?? CursusUser()
        user.cursusUsers.forEach { cursus in
            if cursus.beginAt > latestCursus.beginAt {
                latestCursus = cursus
            }
        }
        return latestCursus
    }
    @State private var locationStats = [String: String]()
    @State private var coalitions = [Coalition]()
    @State private var currentCoalition = Coalition()
    @State private var currentCursus = CursusUser()
    @State private var currentCampus = Campus()
    @State private var color: Color = .blue
    private var finishedProjects: [ProjectUser] { user.projectsUsers.filter { $0.validated != nil } }
    private var currentProjects: [ProjectUser] { user.projectsUsers.filter { $0.validated == nil } }
    @State private var evaluations: [Correction] = []
    var body: some View {
        VStack {
            ScrollView {
                AsyncImage(url: URL(string: user.image.link)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .display(user.id != api.user.id)
                ZStack {
                    VStack {
                        VStack(alignment: .center) {
                            Image(systemName: currentCoalition.imageURL)
                                .font(.title)
                            Text(currentCoalition.name)
                            Text(user.usualFullName)
                                .font(.title2.bold())
                            Text(user.login)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Wallet")
                                    .foregroundStyle(color)
                                Spacer()
                                Text("\(user.wallet)₳")
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Evaluation points")
                                    .foregroundStyle(color)
                                Spacer()
                                Text("\(user.correctionPoint)")
                            }
                            .padding(.vertical)
                            // TODO change this with a picker
                            HStack {
                                Text("Cursus")
                                    .foregroundStyle(color)
                                Spacer()
                                Text("42 Cursus")
                            }
                            .padding(.vertical)
                            HStack {
                                Text("Grade")
                                    .foregroundStyle(color)
                                Spacer()
                                Text("\(selectedCursus.grade ?? "N/A")")
                            }
                            .padding(.vertical)
                        }
                        .padding(.vertical)
                        .padding(.horizontal, 60)
                        .background(Color("CustomBlack"))
                        .clipShape(Rectangle())
                        .padding()
                        // TODO add weekly attendance
                        if let blackholedAt = selectedCursus.blackholedAt {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Blackholed at")
                                        .foregroundStyle(color)
                                    Spacer()
                                }
                                Text("\(blackholedAt.formattedDate(format: "dd/MM/yyyy"))")
                                    .font(.title)
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 60)
                            .background(Color("CustomBlack"))
                            .clipShape(Rectangle())
                            .padding()
                        }
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width - 20, height: 20)
                                .foregroundStyle(.ultraThinMaterial)
                            Rectangle()
                                .frame(width: (UIScreen.main.bounds.width - 20) * selectedCursus.level.truncatingRemainder(dividingBy: 1), height: 20)
                                .foregroundStyle(color)
                            HStack {
                                Spacer()
                                Text("level \(selectedCursus.level, specifier: "%.0f") - \(selectedCursus.level.truncatingRemainder(dividingBy: 1) * 100,  specifier: "%.0f")%")
                                Spacer()
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding()
                    }
                    .padding(.top)
                    .background(
                        AsyncImage(url: URL(string: currentCoalition.coverURL)) { image in
                            image
                                .resizable()
                                .onAppear {
                                    api.isLoading = false
                                }
                        } placeholder: {
                            ProgressView()
                                .onAppear {
                                    api.isLoading = true
                                }
                        }
                    )
                }
                VStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "envelope")
                            Text(user.email)
                                .foregroundStyle(color)
                        }
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(user.campus.first?.name ?? "Unknown Campus")
                                .foregroundStyle(color)
                        }
                    }
                }
                .display(user.id != api.user.id)
                .padding(.vertical)
                .frame(maxWidth: .infinity)
                .background(.gray)
                EventView(api: api)
                    .display(user.id == api.user.id)
                LogtimeView(locationStats: locationStats, startDate: selectedCursus.beginAt)
                HStack {
                    VStack {
                        ForEach(TabProfile.allCases, id: \.self) { tab in
                            Image(systemName: tab.image)
                                .padding(5)
                                .background(tab == selectedTab ? Color.gray.opacity(0.2) : .clear)
                                .onTapGesture {
                                    selectedTab = tab
                                }
                                .padding(.vertical, 5)
                        }
                    }
                    VStack {
                        switch selectedTab {
                        case .projects:
                            ProjectView(api: api, finishedProjects: finishedProjects)
                        case .achievements:
                            AchievementsView(user: user)
                        case .patronage:
                            ScrollView {}
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                HStack {
                    CurrentProjectView(currentProjects: currentProjects, api: api, user: user)
                    Spacer()
                }
                SkillsView(currentCursus: selectedCursus)
            }
            .foregroundStyle(.white)
        }
        .onAppear {
            api.isLoading = true
            if api.user.id == user.id {
                coalitions = api.coalitions
                locationStats = api.locationStats
                currentCoalition = coalitions.first!
                color = currentCoalition.color.toColor()
            } else {
                Task {
                    do {
                        coalitions = try await api.fetchData(API.CoalitionEndPoint.coalition(id: user.id))
                        locationStats = try await api.fetchData(API.LogtimeEndPoint.location(id: user.id, startDate: selectedCursus.beginAt))
                        currentCoalition = coalitions.first!
                        color = currentCoalition.color.toColor()
                    } catch {
                        api.alertTitle = error.localizedDescription
                        api.showAlert = true
                        api.activeTab = .profile
                    }
                }
            }
            
            api.currentCursus = api.getCurrentCursus(from: user.cursusUsers)
            api.currentCampus = api.getCurrentCampus(from: user.campus)
            api.isLoading = false
        }
    }
}

#Preview {
    ProfileView(api: API(), user: User())
}
