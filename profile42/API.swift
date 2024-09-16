//
//  API.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

class API: ObservableObject {
    @Published var token: String = ""
    @Published var user = User()
    @Published var coalitions = [Coalition]()
    @Published var currentCoalition = Coalition()
    @Published var currentCursus = CursusUser()
    @Published var isLoading = true
    let baseAPIString = "https://api.intra.42.fr/v2/"
    
    func getCurrentCursus() -> CursusUser {
        var lastCursus = user.cursusUsers.first!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.sss'Z'"
        for cursusUser in user.cursusUsers {
            if cursusUser.beginAt > lastCursus.beginAt {
                lastCursus = cursusUser
            }
        }
        return lastCursus
    }
    
    func fetchData<T: Decodable>(_ path: APIPath) async throws -> T {
        let APIString = baseAPIString + path.path
        guard let apiURL = URL(string: APIString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        print(token)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
}

enum APIPath {
    case authenticate
    case coalition(id: Int)
    
    var path: String {
        switch self {
        case .authenticate:
            return "me"
        case .coalition(let id):
            return "users/\(id)/coalitions"
        }
    }
}
