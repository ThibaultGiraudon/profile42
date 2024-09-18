//
//  SkillsView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI
import Charts

struct SkillsView: View {
    @StateObject var api: API
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
            Chart(api.currentCursus.skills) { skill in
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
                                selectedSkill = updateSelectedMonth(at: location, proxy: proxy, geometry: geometry)
                                print(selectedSkill ?? "No Skill Selected")
                                showDetails = true
                            }
                        VStack {
                            if let skill = selectedSkill {
                                Text(skill.name)
                                    .font(.headline)
                                Text(String(skill.level))
                                    .font(.title)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func updateSelectedMonth(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> CursusUser.Skills? {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x
        guard let skill: String = proxy.value(atX: xPosition) else {
            return nil
        }
        if let index = api.currentCursus.skills.firstIndex(where: { $0.name == skill }) {
            return api.currentCursus.skills[index]
        }
        return nil
    }
    
}

#Preview {
    SkillsView(api: API())
}
