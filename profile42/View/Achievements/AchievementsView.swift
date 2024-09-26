//
//  AchievementsView.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI
import SwiftSVG

struct SVGImageView: UIViewRepresentable {
    let svgName: String

    class Coordinator {
        func fetchSVGData(for url: URL, completion: @escaping (Data?) -> Void) {
            Task {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        print("Server error")
                        completion(nil)
                        return
                    }
                    completion(data)
                } catch {
                    print("Erreur lors du téléchargement de l'image SVG : \(error)")
                    completion(nil)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let svgView = UIView()

        var svgString = svgName
        if svgString.hasPrefix("/uploads") {
            svgString.removeFirst(9)
            svgString = "https://cdn.intra.42.fr/\(svgString)"
        }
        guard let url = URL(string: svgString) else {
            return svgView
        }

        context.coordinator.fetchSVGData(for: url) { data in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                let svgSubview = UIView(svgData: data)
                
                svgView.addSubview(svgSubview)
            }
        }

        return svgView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}



struct AchievementsView: View {
    var user: User
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Text("LAST ACHIEVEMENTS")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllAchievementsView(user: user)) {
                    Text("SEE ALL ACHIEVEMENTS")
                        .padding(5)
                        .overlay {
                            Rectangle()
                                .stroke(.cyan, lineWidth: 1)
                        }
                        .foregroundStyle(.cyan)
                }
            }
            ForEach(user.achievements.prefix(5), id: \.id) { achievement in
                HStack {
                    VStack(alignment: .leading) {
                        Text(achievement.name)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.subheadline)
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.cyan)
                            VStack {
                                Text("Achieved")
                                    .foregroundStyle(.cyan)
                            }
                        }
                    }
                    .padding()
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        SVGImageView(svgName: achievement.image)
                            .frame(width: 50, height: 50)
                        if achievement.tier.isEmpty { }
                        else if achievement.tier == "easy" {
                            Text("Bronze")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.brown)
                        }
                        else if achievement.tier == "medium" {
                            Text("Silver")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.gray)
                        }
                        else if achievement.tier == "hard" {
                            Text("Gold")
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.yellow)
                        }
                        Spacer()
                    }
                    .frame(width: 80)
                    .background(Color.gray.opacity(0.3))
                }
                .frame(width: 300, height: 150)
                .overlay {
                    Rectangle()
                        .stroke(.gray.opacity(0.3), lineWidth: 3)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsView(user: User())
    }
}
