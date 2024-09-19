//
//  ProjectView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

struct ProjectView: View {
    var finishedProjects: [ProjectUser]
    var body: some View {
        ScrollView {
            ForEach(finishedProjects, id: \.id) { project in
                HStack {
                    Text(project.project.name)
                        .foregroundStyle(.cyan)
                        .bold()
                    Text(project.updatedAt.prefix(10))
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Spacer()
                    Image(systemName: project.validated! ? "checkmark" : "xmark")
                        .foregroundStyle(project.validated! ? .green : .red)
                    Text("\(project.finalMark!)")
                        .foregroundStyle(project.validated! ? .green : .red)
                        .bold()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ProjectView(finishedProjects: [ProjectUser]())
}

// open and load data from project.json as ProjectUser

let projectsUsers: [ProjectUser] = decode("project.json")

func decode<T: Codable>(_ file: String) -> T {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Faliled to locate \(file) in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load file from \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        
    guard let loadedFile = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle")
        }
        
        return loadedFile
    }
