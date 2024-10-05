//
//  EventView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

struct EventView: View {
    @StateObject var api: API
    var body: some View {
        VStack {
            HStack {
                Text("AGENDA")
                    .font(.headline)
                    .foregroundStyle(.black)
                Spacer()
                Text("ALL")
                    .padding(5)
                    .overlay {
                        Rectangle()
                            .stroke(.cyan, lineWidth: 1)
                    }
                    .foregroundStyle(.cyan)
                    .onTapGesture {
                        Task {
                            do {
                                api.events = try await api.fetchData(API.EventEndPoints.events(campusID: api.currentCampus.id, cursusID: api.currentCursus.cursusID))
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .padding(.horizontal)
                Text("SUBSCRIBED")
                    .padding(5)
                    .overlay {
                        Rectangle()
                            .stroke(.cyan, lineWidth: 1)
                    }
                    .foregroundStyle(.cyan)
                    .onTapGesture {
                        Task {
                            do {
                                api.events = try await api.fetchData(API.EventEndPoints.subscribed(id: api.user.id))
                            } catch {
                                print(error)
                            }
                        }
                    }
            }
            ScrollView(showsIndicators: false) {
                ForEach(api.events, id: \.id) { event in
                    var color: Color {
                        if event.kind == "hackathon" {
                            return .green
                        }
                        if event.kind == "association" {
                            return .purple
                        }
                        return .cyan
                    }
                    HStack {
                        VStack {
                            Text(event.beginAt.getDay())
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                            Text(event.beginAt.getMonth())
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 100, height: 100)
                        .background(color)
                        VStack(alignment: .leading) {
                            Text(event.kind)
                                .font(.headline)
                            HStack(alignment: .top) {
                                Text(event.name)
                                    .foregroundStyle(.black.opacity(0.5))
                            }
                            HStack {
                                Image(systemName: "calendar")
                                Text(event.beginAt.getHour())
                                Spacer()
                                Image(systemName: "clock")
                                Text(getDuration(event.beginAt, event.endAt))
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(event.location)
                            }
                        }
                        .frame(height: 100)
                    }
                    .foregroundStyle(color)
                    .overlay {
                        Rectangle()
                            .stroke(color, lineWidth: 2)
                    }
                    .onTapGesture {
                        api.selectedEvent = event
                        api.activeTab = .event
                    }
                }
            }
            .overlay {
                if api.events.isEmpty {
                    VStack {
                        Image(systemName: "calendar.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray.opacity(0.5))
                        Text("No events found")
                            .font(.headline)
                            .foregroundStyle(.gray.opacity(0.5))
                    }
                }
            }
            .frame(height: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    func getDuration(_ beginAt: String, _ endAt: String) -> String {
        let duration = Calendar.current.dateComponents([.hour], from: beginAt.toDate(), to: endAt.toDate()).hour ?? 0
        if duration > 24 {
            let days = duration / 24
            return String(days) + " days"
        }
        return String(duration) + " hour"
    }
    
    func getRemainingTime(_ beginAt: String) -> String {
        let duration = Calendar.current.dateComponents([.hour], from: Date(), to: beginAt.toDate()).hour ?? 0
        if duration > 24 {
            let days = duration / 24
            return  "in " + String(days) + " days"
        }
        return "in " + String(duration) + " hour"
    }
}

#Preview {
    EventView(api: API())
}
