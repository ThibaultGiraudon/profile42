//
//  CurrentProjectView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

struct CurrentProjectView: View {
    @StateObject var api: API
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("PROJECTS")
                    .font(.headline)
                    .padding(.bottom)
                Spacer()
                NavigationLink(destination: EvaluationLogsView(api: api)) {
                    Text("EVALUATION LOGS")
                        .padding(5)
                        .overlay {
                            Rectangle()
                                .stroke(.cyan, lineWidth: 1)
                        }
                        .foregroundStyle(.cyan)
                }
            }
            ForEach(api.currentProjects, id: \.id) { project in
                Text(project.project.name)
                    .foregroundStyle(.cyan)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CurrentProjectView(api: API())
    }
}
