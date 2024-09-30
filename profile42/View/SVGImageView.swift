//
//  SVGImageView.swift
//  profile42
//
//  Created by Thibault Giraudon on 30/09/2024.
//

import SwiftUI
import SwiftSVG

struct SVGImageView: UIViewRepresentable {
    @Binding var svgName: String
    let size: CGRect

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
                    print(url)
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
        loadSVG(svgView: svgView, context: context)
        return svgView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // L'appel de mise à jour se déclenche lorsque svgName change
        loadSVG(svgView: uiView, context: context)
    }
    
    // Helper function pour charger les données SVG
    private func loadSVG(svgView: UIView, context: Context) {
        var svgString = svgName
        if svgString.hasPrefix("/uploads") {
            svgString.removeFirst(9)
            svgString = "https://cdn.intra.42.fr/\(svgString)"
        }
        guard let url = URL(string: svgString) else {
            return
        }

        context.coordinator.fetchSVGData(for: url) { data in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                svgView.subviews.forEach { $0.removeFromSuperview() } // Remove old subviews
                let svgSubview = UIView(svgData: data) { svgLayer in
                    svgLayer.resizeToFit(size)
                }
                
                svgView.addSubview(svgSubview)
            }
        }
    }
}
