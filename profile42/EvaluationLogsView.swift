//
//  EvaluationLogsView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI
import Charts

extension String {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "MMMM dd, yyyy HH:mm"
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
    }
}

struct EvaluationLogsView: View {
    var api: API
    var user: User
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        numberFormatter.positivePrefix = "+"
        return numberFormatter
    }()
    @State private var evaluationLogs = [Correction]()
    var body: some View {
        VStack {
            Text("Evalution Points Historics")
                .font(.title2)
            Chart(evaluationLogs.sorted { $0.createdAt < $1.createdAt }) { evaluation in
                AreaMark(
                    x: .value("Date", evaluation.createdAt),
                    y: .value("Points", evaluation.total + evaluation.sum)
                    )
                .foregroundStyle(.cyan)
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 300)
            .padding()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(evaluationLogs) { evaluation in
                        HStack {
                            VStack {
                                Text(numberFormatter.string(for: evaluation.sum) ?? "0")
                                    .font(.title2.bold())
                                    .foregroundStyle(evaluation.sum > 0 ? .green : .red)
                                    .frame(width: 30, height: 30)
                                    .background(evaluation.sum > 0 ? .green.opacity(0.2) : .red.opacity(0.2))
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                Text(evaluation.reason)
                                    .font(.title2.bold())
                                Text("\(evaluation.total + evaluation.sum) points - \( evaluation.createdAt.formattedDate())")
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                Task {
                    do {
                        evaluationLogs = try await api.fetchData(API.CorrectionEndpoint.correction(id: user.id))
                    } catch {
                        
                    }
                }
            }
        }
    }
}

#Preview {
    EvaluationLogsView(api: API(), user: User())
}
