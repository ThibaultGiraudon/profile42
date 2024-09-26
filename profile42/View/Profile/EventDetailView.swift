//
//  EventDetailView.swift
//  profile42
//
//  Created by Thibault Giraudon on 26/09/2024.
//

import SwiftUI

struct EventDetailView: View {
    @StateObject var api: API
    var event: Event
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
    var body: some View {
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
            .frame(height: 150)
            .foregroundStyle(.white)
            ScrollView {
                Text(formatText(event.description))
                    .foregroundStyle(.black)
            }
            .padding(.horizontal)
            Divider()
            HStack {
                Spacer()
                Button("Close") {
                    api.activeTab = .profile
                }
                .foregroundStyle(.cyan)
                .padding(10)
                .overlay {
                    Rectangle()
                        .stroke(.gray, lineWidth: 1)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .compositingGroup()
        .shadow(radius: 10)
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
    EventDetailView(api: API(), event: Event())
}
