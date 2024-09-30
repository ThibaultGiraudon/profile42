//
//  AchievementsView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI



struct AchievementsView: View {
    var user: User
    @State private var achievements: [Achievement].SubSequence = []
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Text("LAST ACHIEVEMENTS")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllAchievementsView(user: user)) {
                    Text("SEE ALL ACHIEVEMENTS")
                        .padding(5)
                        .overlay {
                            Rectangle()
                                .stroke(.cyan, lineWidth: 1)
                        }
                        .foregroundStyle(.cyan)
                }
            }
            ForEach($achievements, id: \.id) { $achievement in
                HStack {
                    VStack(alignment: .leading) {
                        Text(achievement.name)
                            .font(.headline)
                            .foregroundStyle(.black)
                        Text(achievement.description)
                            .font(.subheadline)
                            .foregroundStyle(.black)
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
                        SVGImageView(svgName: $achievement.image, size: CGRect(x: 0, y: 0, width: 50, height: 50))
                            .frame(width: 50, height: 50)
                        if achievement.tier.isEmpty { }
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
            achievements = user.achievements.prefix(5)
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsView(user: User())
    }
}
