//
//  LogtimeView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: self) ?? Date()
    }
}

struct LogtimeView: View {
    var locationStats: [String: String]
    var startDate: String
    @State private var showOverlay: Bool = false
    @State private var selectedDate: Date?
    let date: Date = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_EN")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    private var back: Int {
        Calendar.current.dateComponents([.month], from: Date(), to: startDate.toDate()).month ?? 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("LOGTIME")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(generateMonths(back: back, from: date), id: \.self) { month in
                        VStack {
                            Text("\(dateFormatter.string(from: month))")
                                .foregroundStyle(.black)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach(generateDays(for: month), id: \.self) { day in
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .foregroundStyle(.black)
                                        .frame(width: 30, height: 30)
                                        .background (
                                            isDate(in: locationStats, date: day) ? .blue.opacity(getOpacity(for: day)) : .gray.opacity(0.1)
                                        )
                                        .zIndex(1)
                                        .onTapGesture {
                                            showOverlay = true
                                            selectedDate = day
                                        }
                                        .overlay {
                                            if showOverlay && selectedDate == day {
                                                ZStack {
                                                    Color.black.opacity(0.8)
                                                    Text("\(getValue(for: day))")
                                                        .foregroundStyle(.white)
                                                }
                                                .frame(width: 80, height: 50)
                                                .offset(y: -40)
                                            }
                                        }
                                        .zIndex(2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .defaultScrollAnchor(.trailing)
        }
    }
    
    func isDate(in location: [String: String], date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let dateString = formatter.string(from: date)
        return location.keys.contains(dateString)
    }
    
    func getOpacity(for date: Date) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let dateString = formatter.string(from: date)
        let value = locationStats[dateString]!
        let hour = Double(value.prefix(2)) ?? 0
        let subString = value.dropFirst(3)
        let minute = Double((Int(subString.prefix(2)) ?? 0) / 60)
        return Double((hour + minute) / 24)
    }
    
    func getValue(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let dateString = formatter.string(from: date)
        let value = locationStats[dateString]
        guard let value else { return "0h00" }
        let newValue = value.replacingOccurrences(of: ":", with: "h")
        return String(newValue.prefix(5))
    }
    
    func generateMonths(back past: Int, from date: Date) -> [Date] {
        var month: [Date] = []
        for i in past...0 {
            let date = Calendar.current.date(byAdding: .month, value: i, to: date)!
            month.append(date)
        }
        return month
    }
    
    func generateDays(for date: Date) -> [Date] {
        var days: [Date] = []
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else { return [] }
        
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
}

#Preview {
    let locationStats = ["2024-08-21":"04:20:59.4398","2024-08-14":"06:21:01.901664","2024-08-04":"11:24:18.531457","2024-08-03":"13:02:41.865","2024-08-02":"05:54:59.202939","2024-08-01":"04:14:00.18825","2024-07-31":"11:49:18.01697","2024-07-30":"14:50:44.903031","2024-07-29":"10:25:00.933241","2024-07-28":"04:51:00.303256","2024-07-25":"10:21:00.042789","2024-06-28":"06:35:00.482362","2024-06-26":"06:31:58.689214","2024-06-25":"06:10:00.616138","2024-06-21":"06:04:00.045311","2024-06-18":"06:40:59.408136","2024-06-16":"06:19:59.995317","2024-06-14":"05:44:00.015018","2024-06-13":"06:23:03.651948","2024-06-12":"06:37:58.565964","2024-06-11":"06:11:00.41953","2024-06-07":"07:48:58.908038","2024-06-05":"08:42:59.980638","2024-05-25":"07:31:59.978881","2024-05-24":"09:59:00.267491","2024-05-23":"06:40:00.079178","2024-05-22":"08:53:00.216747"]
    LogtimeView(locationStats: locationStats, startDate: "2023-10-25T13:20:23.037Z")
}
