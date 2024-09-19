//
//  OtherProfileView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

struct OtherProfileView: View {
    @StateObject var api: API
    @State private var selectedTab: TabProfile = .projects
    @State var user: User
    private var selectedCursus: CursusUser {
        var latestCursus = user.cursusUsers.first!
        user.cursusUsers.forEach { cursus in
            if cursus.beginAt > latestCursus.beginAt {
                latestCursus = cursus
            }
        }
        return latestCursus
    }
    @State private var isLoading: Bool = true
    @State private var locationStats = [String: String]()
    @State private var coalitions = [Coalition]()
    @State private var currentCoalition = Coalition()
    @State private var finishedProjects: [ProjectUser] = []
    @State private var currentProjects: [ProjectUser] = []
    @State private var evaluations: [Correction] = []
    var body: some View {
        VStack {
            if isLoading {
                ScrollView {
                    ProgressView()
                }
            } else {
                ScrollView {
                    AsyncImage(url: URL(string: user.image.link)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    ZStack {
//                        AsyncImage(url: URL(string: currentCoalition.coverURL)) { image in
//                            image
//                                .resizable()
//                        } placeholder: {
//                            ProgressView()
//                        }
                        VStack {
                            VStack(alignment: .center) {
                                Image(systemName: currentCoalition.imageURL)
                                Text(currentCoalition.name)
                                Text(user.usualFullName)
                                    .font(.title2.bold())
                                Text(user.login)
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Wallet")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(user.wallet)₳")
                                }
                                .padding(.vertical)
                                HStack {
                                    Text("Evaluation points")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(user.correctionPoint)")
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
                                    Text("\(selectedCursus.grade ?? "N/A")")
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
                                    .frame(width: (UIScreen.main.bounds.width - 20) * selectedCursus.level.truncatingRemainder(dividingBy: 1), height: 20)
                                    .foregroundStyle(.blue)
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
                            } placeholder: {
                                ProgressView()
                            }
                        )
                    }
                    VStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "envelope")
                                Text(user.email)
                                    .foregroundStyle(.blue)
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(user.campus.first?.name ?? "Unknown Campus")
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.gray)
                    LocationView(locationStats: locationStats, startDate: selectedCursus.beginAt)
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
                                ProjectView(finishedProjects: finishedProjects)
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
        }
        .onAppear {
//            coalitions = decode("coalitions.json")
//            locationStats = decode("locationsStats.json")
//            currentCoalition = coalitions.first!
//            finishedProjects = user.projectsUsers.filter { $0.validated != nil }
//            currentProjects = user.projectsUsers.filter { $0.validated == nil }
//            evaluations = decode("evaluationLogs.json")
//            isLoading = false
            Task {
                do {
                    print(user.login)
                    coalitions = try await api.fetchData(API.UserEndPoint.coalition(id: user.id))
                    currentCoalition = coalitions.first!
                    finishedProjects = user.projectsUsers.filter { $0.validated != nil }
                    currentProjects = user.projectsUsers.filter { $0.validated == nil }
                    locationStats = try await api.fetchData(API.LocationEndPoint.location(id: user.id, startDate: selectedCursus.beginAt))
//                    evaluations = try await api.fetchData(API.CorrectionEndpoint.correction(id: user.id))
                    isLoading = false
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    let user: User = decode("user.json")
    OtherProfileView(api: API(), user: user)
}
