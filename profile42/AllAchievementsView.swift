//
//  AchievementsView 2.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

enum Kind: String, CaseIterable {
    case all, project, social, scolarity, pedagogy
    
    var image: String {
        switch self {
        case .all:
            "BADGE_ALL"
        case .project:
            "BADGE_PROJECT"
        case .social:
            "BADGE_SOCIAL"
        case .scolarity:
            "BADGE_SCOLARITY"
        case .pedagogy:
            "BADGE_PEDAGOGY"
        }
    }
}

enum FilterBy: String, CaseIterable {
    case none, bronze, silver, gold, platinum
    
    var name: String {
        switch self {
        case .none:
            "none"
        case .bronze:
            "easy"
        case .silver:
            "medium"
        case .gold:
            "hard"
        case .platinum:
            "very hard"
        }
    }
}

struct AllAchievementsView: View {
    @StateObject var api: API
    @State private var selectedRank: FilterBy = .none
    @State private var selectedKind: Kind = .all
    var filteredAchievement: [Achievement] {
        api.user.achievements.filter{ (selectedKind == .all ? true : $0.kind == selectedKind.rawValue) && $0.tier == selectedRank.name }
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                ForEach(Kind.allCases, id: \.self) { kind in
                    VStack {
                        Image(kind.image)
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(kind.rawValue)
                            .padding(5)
                            .overlay {
                                if selectedKind == kind {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1)
                                }
                            }
                    }
                    .onTapGesture {
                        selectedKind = kind
                    }
                }
            }
            VStack {
                Text("Filter by rank")
                Picker("", selection: $selectedRank) {
                    ForEach(FilterBy.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(.palette)
            }
            ForEach(filteredAchievement, id: \.id) { achievement in
                HStack {
                    VStack(alignment: .leading) {
                        Text(achievement.name)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.subheadline)
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.cyan)
                            VStack {
                                Text("Achieved")
                                    .foregroundStyle(.cyan)
                            }
                        }
                    }
                    .padding()
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        SVGImageView(svgName: achievement.image)
                            .frame(width: 50, height: 50)
                        if achievement.tier == "none" {
                            
                        }
                        else if achievement.tier == "easy" {
                            Text("Bronze")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.brown)
                        }
                        else if achievement.tier == "medium" {
                            Text("Silver")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.gray)
                        }
                        else if achievement.tier == "hard" {
                            Text("Gold")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.yellow)
                        }
                        else {
                            Text("Platinium")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.gray.opacity(0.8))
                        }
                        Spacer()
                    }
                    .frame(width: 80)
                    .background(Color.gray.opacity(0.3))
                }
                .frame(width: 300, height: 150)
                .overlay {
                    Rectangle()
                        .stroke(.gray.opacity(0.3), lineWidth: 3)
                }
            }
        }
        .onAppear {
            api.user.achievements = decode("achievement.json")
        }
    }
}

#Preview() {
    AllAchievementsView(api: API())
}
