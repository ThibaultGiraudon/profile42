//
//  EventView.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

extension String {
    func getDay() -> String {
        let stripped = self.dropFirst(8)
        return String(stripped.prefix(2))
    }
    
    func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "MMM"
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
    }
    
    func getHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "HH:mm"
        return strFormatter.string(from: dateFormatter.date(from: self) ?? Date())
        
    }
}

struct EventView: View {
    @StateObject var api: API
    var events: [Event]
    var completion: ((Event) -> Void)
    @State private var showingDetail: Bool = false
    @State private var selectedEvent: Event?
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                HStack {
                    Text("AGENDA")
                        .font(.headline)
                        .foregroundStyle(.black)
                    Spacer()
                }
                ForEach(events, id: \.id) { event in
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
//                        showingDetail = true
                        selectedEvent = event
                        completion(event)
                    }
                }
            }
            .frame(height: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .padding()
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
    EventView(api: API(), events: events) {_ in 
        
    }
}
