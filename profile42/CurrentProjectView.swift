//
//  CurrentProjectView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

struct CurrentProjectView: View {
    var currentProjects: [ProjectUser]
    var api: API
    var user: User
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("PROJECTS")
                    .foregroundStyle(.black)
                    .font(.headline)
                    .padding(.bottom)
                Spacer()
                NavigationLink(destination: EvaluationLogsView(api: api, user: user)) {
                    Text("EVALUATION LOGS")
                        .padding(5)
                        .overlay {
                            Rectangle()
                                .stroke(.cyan, lineWidth: 1)
                        }
                        .foregroundStyle(.cyan)
                }
            }
            ForEach(currentProjects, id: \.id) { project in
                Text(project.project.name)
                    .foregroundStyle(.cyan)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CurrentProjectView(currentProjects: [], api: API(), user: User())
    }
}
