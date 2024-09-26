//
//  ProjectDetailView.swift
//  profile42
//
//  Created by Thibault Giraudon on 20/09/2024.
//

import SwiftUI

struct ProjectDetailView: View {
    @StateObject var api: API
    @State private var evaluations = [Evaluation]()
    @State private var firstEvaluation = Evaluation()
    var body: some View {
        VStack {
            Text(api.selectedProject.project.name)
                .font(.title)
                .padding(.vertical)
            VStack(alignment: .center) {
                HStack {
                    Image(systemName: api.selectedProject.validated != nil && api.selectedProject.validated! ? "checkmark" : "xmark")
                    Text(api.selectedProject.validated != nil && api.selectedProject.validated! ? "SUCCESS" : "FAILURE")
                }
                HStack(spacing: 0) {
                    Text("\(api.selectedProject.finalMark ?? 0)")
                        .font(.title)
                    Text("/100")
                }
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(api.selectedProject.validated != nil && api.selectedProject.validated! ? .green : .red)
            if firstEvaluation.id != 0 {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(firstEvaluation.team.name)
                                .foregroundStyle(.cyan)
                                .font(.title3.bold())
                            Spacer()
                            Text("\(api.selectedProject.finalMark ?? 0)%")
                                .foregroundStyle((api.selectedProject.finalMark ?? 0) >= 80 ? .green : .red)
                        }
                        // TODO add This team was locked 5 months ago and closed 5 months ago
                        Divider()
                        Text("USERS - \(firstEvaluation.team.users.count) USERS IN THIS TEAM")
                            .font(.callout)
                            .foregroundStyle(.gray.opacity(0.5))
                        HStack {
                            ForEach(firstEvaluation.team.users, id: \.id) { user in
                                Text(user.login)
                                    .font(.callout)
                            }
                        }
                        .padding(10)
                        Divider()
                        Text("GIT REPOSITORIE")
                            .font(.callout)
                            .foregroundStyle(.gray.opacity(0.5))
                        HStack(spacing: 0) {
                            Text(firstEvaluation.team.repoURL)
                                .padding()
                                .background(.gray.opacity(0.1))
                                .lineLimit(1)
                            Image(systemName: "document.on.clipboard")
                                .padding()
                                .background(.gray.opacity(0.3))
                                .onTapGesture {
                                    UIPasteboard.general.string = firstEvaluation.team.repoURL
                                }
                        }
                        Divider()
                        Text("EVALUATIONS")
                            .font(.callout)
                            .foregroundStyle(.gray.opacity(0.5))
                        ForEach(evaluations, id: \.id) { evaluation in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("EVALUATED BY ")
                                        .font(.caption)
                                        .foregroundStyle(.gray.opacity(0.5))
                                    Text(evaluation.corrector.login.uppercased())
                                        .font(.caption.bold())
                                        .foregroundStyle(.cyan)
                                    Text(" \(getDuration(from: evaluation.updatedAt)) AGO")
                                        .font(.caption.bold())
                                        .foregroundStyle(.gray)
                                    Spacer()
                                    Image(systemName: (evaluation.finalMark ?? 0) >= 80 ? "checkmark.circle" : "xmark.circle")
                                        .foregroundStyle((evaluation.finalMark ?? 0) >= 80 ? .green : .red)
                                        .font(.callout)
                                    Text(" \(evaluation.finalMark ?? 0)%")
                                        .font(.callout)
                                        .foregroundStyle((evaluation.finalMark ?? 0) >= 80 ? .green : .red)
                                }
                                .padding(.vertical, 5)
                                HStack {
                                    Text(evaluation.comment ?? "No comment yet")
                                        .font(.caption)
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(.gray.opacity(0.2))
                                    Spacer()
                                }
                                Text("YOUR FEEDBACK, \(getDuration(from: firstEvaluation.updatedAt)) AGO")
                                    .font(.caption)
                                    .foregroundStyle(.gray.opacity(0.5))
                                    .padding(.vertical, 5)
                                VStack(alignment: .leading) {
                                    Text(evaluation.feedbacks.first?.comment ?? "No feedback yet")
                                        .font(.caption)
                                        .padding(10)
                                    Divider()
                                        .padding(.horizontal, 10)
                                    HStack {
                                        ForEach(0..<5) { index in
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(index <= evaluation.feedbacks.first?.rating ?? 0 ? .green : .gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(10)
                                }
                                .frame(maxWidth: .infinity)
                                .background(.gray.opacity(0.2))
                            }
                        }
                        .padding(10)
                    }
                    .padding()
                    .overlay {
                        Rectangle()
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    }
                }
            } else {
                Spacer()
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    api.evaluations = try await api.fetchData(API.EvalutaionEndPoint.corrected(id: api.selectedUser.id == 0 ? api.user.id : api.selectedUser.id))
                    evaluations = api.getEvaluations(for: api.selectedProject.currentTeamID ?? 0)
                    if !evaluations.isEmpty {
                        firstEvaluation = evaluations.first!
                    }
                } catch {
                    api.activeTab = .profile
                    api.navHistory.append(.profile)
                    print(error)
                }
            }
        }
    }
    
    func getDuration(from date: String) -> String {
        let duration = Calendar.current.dateComponents([.minute], from: date.toDate(), to: Date()).minute ?? 0
        if duration > 60 * 24 * 365 {
            let years = duration / (60 * 24 * 365)
            return String(years) + " YEARS"
        }
        if duration > 60 * 24 * 30 {
            let months = duration / (60 * 24 * 30)
            return String(months) + " MONTHS"
        }
        if duration > 60 * 24 {
            let days = duration / (60 * 24)
            return String(days) + " DAYS"
        }
        if duration > 60 {
            let days = duration / 24
            return String(days) + " HOURS"
        }
        return String(duration) + " MINUTES"
    }
    
}

enum MyError: Error {
    case runtimeError(String)
}

#Preview {
    ProjectDetailView(api: API())
}
