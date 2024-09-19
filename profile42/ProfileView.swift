//
//  ProfileView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var api: API
    var events: [Event]
    @State private var selectedTab: TabProfile = .projects
    private var selectedCursus: CursusUser {
        var latestCursus = api.user.cursusUsers.first!
        api.user.cursusUsers.forEach { cursus in
            if cursus.beginAt > latestCursus.beginAt {
                latestCursus = cursus
            }
        }
        return latestCursus
    }
    @State private var isLoading: Bool = true
    @State private var locationStats = [String: String]()
    @State private var coalitions = [Coalition]()
    @State private var currentCoalition = Coalition()
    @State private var finishedProjects: [ProjectUser] = []
    @State private var currentProjects: [ProjectUser] = []
    @State private var evaluations: [Correction] = []
    @State private var selectedEvent: Event?
    @State private var showingDetail: Bool = false
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                ScrollView {
                    ZStack {
                        AsyncImage(url: URL(string: currentCoalition.coverURL)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        VStack {
                            VStack(alignment: .center) {
                                Image(systemName: currentCoalition.imageURL)
                                Text(currentCoalition.name)
                                Text(api.user.usualFullName)
                                    .font(.title2.bold())
                                Text(api.user.login)
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Wallet")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(api.user.wallet)₳")
                                }
                                .padding(.vertical)
                                HStack {
                                    Text("Evaluation points")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(api.user.correctionPoint)")
                                }
                                .padding(.vertical)
                                // TODO change this with a picker
                                HStack {
                                    Text("Cursus")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("42 Cursus")
                                }
                                .padding(.vertical)
                                HStack {
                                    Text("Grade")
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("\(selectedCursus.grade ?? "N/A")")
                                }
                                .padding(.vertical)
                            }
                            .padding(.vertical)
                            .padding(.horizontal, 60)
                            .background(.gray)
                            .clipShape(Rectangle())
                            .padding()
                            // TODO add weekly attendance
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: 20)
                                    .foregroundStyle(.ultraThinMaterial)
                                Rectangle()
                                    .frame(width: (UIScreen.main.bounds.width - 20) * selectedCursus.level.truncatingRemainder(dividingBy: 1), height: 20)
                                    .foregroundStyle(.blue)
                                HStack {
                                    Spacer()
                                    Text("level \(selectedCursus.level, specifier: "%.0f") - \(selectedCursus.level.truncatingRemainder(dividingBy: 1) * 100,  specifier: "%.0f")%")
                                    Spacer()
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding()
                        }
                        .padding(.top)
                    }
                    VStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "envelope")
                                Text(api.user.email)
                                    .foregroundStyle(.blue)
                            }
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(api.user.campus.first?.name ?? "Unknown Campus")
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.gray)
                    EventView(api: api, events: events) { event in
                        selectedEvent = event
                        showingDetail = true
                    }
                    .frame(height: .infinity)
                    LocationView(locationStats: locationStats, startDate: selectedCursus.beginAt)
                    HStack {
                        VStack {
                            ForEach(TabProfile.allCases, id: \.self) { tab in
                                Image(systemName: tab.image)
                                    .foregroundStyle(.black)
                                    .padding(5)
                                    .background(tab == selectedTab ? Color.gray.opacity(0.2) : .clear)
                                    .onTapGesture {
                                        selectedTab = tab
                                    }
                                    .padding(.vertical, 5)
                            }
                        }
                        VStack {
                            switch selectedTab {
                            case .projects:
                                ProjectView(finishedProjects: finishedProjects)
                            case .achievements:
                                AchievementsView(user: api.user)
                            case .patronage:
                                ScrollView {}
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    HStack {
                        CurrentProjectView(currentProjects: currentProjects, api: api, user: api.user)
                        Spacer()
                    }
                    SkillsView(currentCursus: selectedCursus)
                }
                .foregroundStyle(.white)
                .overlay {
                    if showingDetail {
                        if let event = selectedEvent {
                            var color: Color {
                                if event.kind == "hackathon" {
                                    return .green
                                }
                                if event.kind == "association" {
                                    return .purple
                                }
                                return .cyan
                            }
                            var dateFormatter: DateFormatter {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm"
                                return dateFormatter
                            }
                            VStack {
                                ZStack {
                                    Color(color)
                                    VStack(alignment: .center) {
                                        VStack {
                                            Text(event.kind.uppercased())
                                            Text(event.name)
                                                .font(.title2.bold())
                                            Text(dateFormatter.string(from: event.beginAt.toDate()))
                                        }
                                        .padding()
                                        ZStack {
                                            Color.black.opacity(0.3)
                                            HStack {
                                                Image(systemName: "calendar")
                                                Text(getRemainingTime(event.beginAt))
                                                Spacer()
                                                Image(systemName: "clock")
                                                Text(getDuration(event.beginAt, event.endAt))
                                                Spacer()
                                                Image(systemName: "mappin.and.ellipse")
                                                Text(event.location)
                                                Spacer()
                                                Image(systemName: "person.crop.circle")
                                                Text("\(event.nbrSubscribers) / \(event.maxPeople ?? 0)")
                                            }
                                            .padding()
                                        }
                                    }
                                }
                                .frame(width: .infinity, height: 150)
                                .foregroundStyle(.white)
                                ScrollView {
                                    Text(formatText(event.description))
                                }
                                .padding(.horizontal)
                                Divider()
                                HStack {
                                    Spacer()
                                    Button("Close") {
                                        showingDetail = false
                                    }
                                    .foregroundStyle(.cyan)
                                    .padding(10)
                                    .overlay {
                                        Rectangle()
                                            .stroke(.gray, lineWidth: 1)
                                    }
                                    Button(event.maxPeople != nil && event.nbrSubscribers >= event.maxPeople! ? "The event is full" : "Subscribe") {
                                        // TODO subscribe to event
                                    }
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(Color.cyan.opacity(event.maxPeople != nil && event.nbrSubscribers >= event.maxPeople! ? 0.6 : 1))
                                    .disabled(event.maxPeople == nil ? false : event.nbrSubscribers >= event.maxPeople!)
                                }
                                .padding()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.white)
                            .compositingGroup()
                            .shadow(radius: 10)
                        }
                    }
                }
            }
        }
        .onAppear {
            api.user = decode("user.json")
            coalitions = decode("coalitions.json")
            locationStats = decode("locationsStats.json")
            currentCoalition = coalitions.first!
            finishedProjects = api.user.projectsUsers.filter { $0.validated != nil }
            currentProjects = api.user.projectsUsers.filter { $0.validated == nil }
            evaluations = decode("evaluationLogs.json")
            isLoading = false
//            Task {
//                do {
//                    coalitions = try await api.fetchData(API.UserEndPoint.coalition(id: api.user.id))
//                    currentCoalition = coalitions.first!
//                    finishedProjects = api.user.projectsUsers.filter { $0.validated != nil }
//                    currentProjects = api.user.projectsUsers.filter { $0.validated == nil }
//                    locationStats = try await api.fetchData(API.LocationEndPoint.location(id: api.user.id, startDate: selectedCursus.beginAt))
//                    isLoading = false
//                } catch {
//                    print(error)
//                }
//            }
        }
    }
    
    func formatText(_ rawText: String) -> AttributedString {
        let mutableString = NSMutableAttributedString(string: rawText)
        var nbChar: Int = 0
        var text = rawText
        
        rawText.enumerateSubstrings(in: rawText.startIndex..<rawText.endIndex, options: .byLines) { sub, subRange, _, _ in
            if (sub != nil) && sub!.hasPrefix("#") {
                var nsRange = NSRange(subRange, in: rawText)
                let length: Int = sub!.prefix(while: { (character) -> Bool in
                    return character == "#"
                }).count
                nsRange.location -= nbChar
                mutableString.addAttribute(.font, value: UIFont.systemFont(ofSize: 26), range: nsRange)
                nsRange.length = length
                mutableString.replaceCharacters(in: nsRange, with: "")
                text = text.remove(nsRange: nsRange)
                nbChar += length
            }
        }
        nbChar = 0
        
        var cpyText = text
        let boldPattern = "\\*\\*(.*?)\\*\\*"
        if let regex = try? NSRegularExpression(pattern: boldPattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let range = Range(match.range, in: text) {
                    var nsRange = NSRange(range, in: text)
                    nsRange.location -= nbChar
                    let attribute = mutableString.attributes(at: nsRange.location, effectiveRange: nil)[.font]
                    var size: CGFloat = 18
                    if let font = attribute as? UIFont {
                        size = font.pointSize
                    }
                    mutableString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: size), range: nsRange)
                    let nsRangeLength: Int = nsRange.length
                    nsRange.length = 2
                    mutableString.replaceCharacters(in: nsRange, with: "")
                    cpyText = cpyText.remove(nsRange: nsRange)
                    nsRange.location += nsRangeLength - 4
                    mutableString.replaceCharacters(in: nsRange, with: "")
                    cpyText = cpyText.remove(nsRange: nsRange)
                    nbChar += 4
                }
            }
        }
        
        text = cpyText
        nbChar = 0
        let italicPatern = "\\*(.*?)\\*"
        if let regex = try? NSRegularExpression(pattern: italicPatern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches {
                if let range = Range(match.range, in: text) {
                    var nsRange = NSRange(range, in: text)
                    nsRange.location -= nbChar
                    let attribute = mutableString.attributes(at: nsRange.location, effectiveRange: nil)[.font]
                    var size: CGFloat = 18
                    if let font = attribute as? UIFont {
                        size = font.pointSize
                    }
                    mutableString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: size), range: nsRange)
                    let nsRangeLength: Int = nsRange.length
                    nsRange.length = 1
                    mutableString.replaceCharacters(in: nsRange, with: "")
                    cpyText = cpyText.remove(nsRange: nsRange)
                    nsRange.location += nsRangeLength - 2
                    mutableString.replaceCharacters(in: nsRange, with: "")
                    cpyText = cpyText.remove(nsRange: nsRange)
                    nbChar += 2
                }
            }
        }
        
        let atttributedString = AttributedString(mutableString)
        
        return atttributedString
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
    let events: [Event] = decode("events.json")
    ProfileView(api: API(), events: events)
}
