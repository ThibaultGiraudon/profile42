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
    @State private var coalitionsUsers: [CoalitionUser] = []
    @State private var selectedCursus = CursusUser()
    @State private var selectedCursusName = "42cursus"
    @State private var locationStats = [String: String]()
    @State private var coalitions = [Coalition]()
    @State private var currentCoalition: Coalition?
    @State private var currentCoalitionUser: CoalitionUser?
    @State private var currentCursus = CursusUser()
    @State private var currentCampus = Campus()
    @State private var color: Color = .blue
    @State private var isPresented: Bool = false
    private var finishedProjects: [ProjectUser] { user.projectsUsers.filter { $0.validated != nil && $0.cursusIDs.contains(selectedCursus.cursus.id)} }
    private var currentProjects: [ProjectUser] { user.projectsUsers.filter { $0.validated == nil } }
    @State private var evaluations: [Correction] = []
    var body: some View {
        VStack {
            if isPresented {
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
                                    if selectedCursus.hasCoalition {
                                        if let currentCoalition = currentCoalition, let currentCoalitionUser = currentCoalitionUser {
                                            let imageURL = currentCoalition.imageURL
                                            SVGImageView(svgName: .constant(imageURL), size: CGRect(x: 0, y: 0, width: 50, height: 50))
                                                .frame(width: 50, height: 50)
                                                .padding()
                                                .background(color)
                                            Text(currentCoalition.name)
                                            HStack {
                                                Image(systemName: "trophy.fill")
                                                Text("\(currentCoalitionUser.score)")
                                                Image(systemName: "chevron.up.2")
                                                Text("\(currentCoalitionUser.rank)")
                                            }
                                        }
                                    }
                                    if let title = user.titles.first?.name {
                                        Text(title.replace("%login", with: user.login))
                                    }
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
                                    Picker(selectedCursusName, selection: $selectedCursusName) {
                                        ForEach(user.cursusUsers, id: \.id) { cursus in
                                            Text(cursus.cursus.name).tag(cursus.cursus.name)
                                        }
                                    }
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
                                    Text("level \(Int(selectedCursus.level)) - \(selectedCursus.level.truncatingRemainder(dividingBy: 1) * 100,  specifier: "%.0f")%")
                                    Spacer()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding()
                        }
                        .padding(.top)
                        .background(
                            AsyncImage(url: URL(string: currentCoalition?.coverURL! ?? "https://profile.intra.42.fr/assets/background_login-a4e0666f73c02f025f590b474b394fd86e1cae20e95261a6e4862c2d0faa1b04.jpg")) { image in
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
                                    .foregroundStyle(.black)
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
            else {
                ScrollView {
                    
                }
            }
        }
        .onChange(of: selectedCursusName) {
            selectedCursus = user.cursusUsers.first(where: { $0.cursus.name == selectedCursusName})!
            currentCoalitionUser = getCoalition(from: selectedCursus.updatedAt, in: coalitionsUsers)
            currentCoalition = coalitions.first(where: {
                            for component in selectedCursus.cursus.slug.components(separatedBy: "-") {
                                print(component)
                                if !$0.slug.contains(component) {
                                    print("not found, \(component) in \($0.slug)")
                                    return false
                                }
                            }
                            return true
                        }) ?? coalitions.first(where: { $0.id == currentCoalitionUser?.coalitionId ?? 0 })
            color = currentCoalition?.color.toColor() ?? .cyan
        }
        .onAppear {
            api.isLoading = true
            isPresented = false
            if api.user.id == user.id {
                coalitions = api.coalitions
                locationStats = api.locationStats
            }
            Task {
                do {
                    coalitionsUsers = try await api.fetchData(API.CoalitionEndPoint.coalitionUser(id: user.id))
                    selectedCursus = {
                        var latestCursus = user.cursusUsers.first ?? CursusUser()
                        user.cursusUsers.forEach { cursus in
                            if cursus.beginAt > latestCursus.beginAt {
                                latestCursus = cursus
                            }
                        }
                        return latestCursus
                    }()
                    if api.user.id != user.id {
                        coalitions = try await api.fetchData(API.CoalitionEndPoint.coalition(id: user.id))
                        locationStats = try await api.fetchData(API.LogtimeEndPoint.location(id: user.id, startDate: selectedCursus.beginAt))
                    }
                    currentCoalitionUser = getCoalition(from: selectedCursus.updatedAt, in: coalitionsUsers)
                    currentCoalition = coalitions.first(where: {
                        for component in selectedCursus.cursus.slug.components(separatedBy: "-") {
                            if !$0.slug.contains(component) {
                                return false
                            }
                        }
                        return true
                    }) ?? coalitions.first(where: { $0.id == currentCoalitionUser?.coalitionId ?? 0 })
                    color = currentCoalition?.color.toColor() ?? .cyan
                } catch {
                    print(error)
                    api.alertTitle = error.localizedDescription
                    api.showAlert = true
                    api.activeTab = .profile
                }
            }
            api.currentCursus = api.getCurrentCursus(from: user.cursusUsers)
            api.currentCampus = api.getCurrentCampus(from: user.campus)
            api.isLoading = false
            isPresented = true
        }
    }
    
    func getCoalition(from date: String, in coalitions: [CoalitionUser]) -> CoalitionUser? {
        var returnCoalition: CoalitionUser?
        var lastDelta = 2147483647.0
        
        for coalition in coalitions {
            if coalition.updatedAt == date || coalition.createdAt == date {
                return coalition
            }
            let delta = abs(coalition.createdAt.toDate() - date.toDate())
            if delta < lastDelta {
                lastDelta = delta
                returnCoalition = coalition
            }
        }
        return returnCoalition
    }
}

#Preview {
    ProfileView(api: API(), user: User())
}
