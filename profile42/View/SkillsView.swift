//
//  SkillsView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI
import Charts

struct SkillsView: View {
    var currentCursus: CursusUser
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetails: Bool = false
    @State private var selectedSkill: CursusUser.Skills?
    var body: some View {
        VStack {
            HStack {
                Text("SKILLS")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Spacer()
            }
            Chart(currentCursus.skills) { skill in
                BarMark(
                    x: .value("Name", skill.name),
                    y: .value("Level", skill.level))
                .foregroundStyle(.blue)
            }
            .frame(height: 300)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .onTapGesture { location in
                                selectedSkill = getSkill(at: location, proxy: proxy, geometry: geometry)
                                showDetails = true
                            }
                        VStack {
                            if let skill = selectedSkill {
                                Text(skill.name)
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                Text(String(skill.level))
                                    .font(.title)
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func getSkill(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> CursusUser.Skills? {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x
        guard let skill: String = proxy.value(atX: xPosition) else {
            return nil
        }
        if let index = currentCursus.skills.firstIndex(where: { $0.name == skill }) {
            return currentCursus.skills[index]
        }
        return nil
    }
    
}

#Preview {
    SkillsView(currentCursus: CursusUser())
}
