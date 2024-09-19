//
//  API.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

class API: ObservableObject {
    @Published var accessToken: String = ""
    @Published var applicationToken: String = ""
    @Published var user = User()
    @Published var coalitions = [Coalition]()
    @Published var currentCoalition = Coalition()
    @Published var currentCursus = CursusUser()
    @Published var isLoading = true
    @Published var locationStats = [String: String]()
    @Published var finishedProjects = [ProjectUser]()
    @Published var currentProjects = [ProjectUser]()
    @Published var evaluationLogs = [Correction]()
    @Published var events = [Event]()
    @Published var history = [User]()
    @Published var selectedUser = User()
    @Published var activeTab: Tab = .profile
    
    func getFinihedProjects() -> [ProjectUser] {
        user.projectsUsers.filter { $0.validated != nil }
    }
    
    func getCurrentProjects() -> [ProjectUser] {
        user.projectsUsers.filter { $0.validated == nil }
    }
    
    func getCurrentCursus() -> CursusUser {
        var lastCursus = user.cursusUsers.first!

        for cursusUser in user.cursusUsers {
            if cursusUser.beginAt > lastCursus.beginAt {
                lastCursus = cursusUser
            }
        }
        return lastCursus
    }
    
    func fetchData<T: Decodable>(_ endpoint: API.EndPoint) async throws -> T {
        guard let apiURL = endpoint.url else {
            print("URL error")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        print(accessToken)
        print(applicationToken)
        request.addValue("Bearer \(endpoint.authorization == .application ? applicationToken : accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Server error")
            print(apiURL)
            print((response as? HTTPURLResponse) ?? "Error")
            throw URLError(.badServerResponse)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Decoding error")
            throw error
        }
    }
    
    func exchangeCodeForToken(endpoint: API.AuthEndPoint) async throws -> String {
        guard let tokenURL = endpoint.url else {
            print("URL error")
            throw URLError(.badURL)
        }
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Server error")
            print(String(data: data, encoding: .utf8) ?? "")
            throw URLError(.badServerResponse)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let token = json["access_token"] as? String {
                return token
            }
        } catch {
            print("Error parsing token response")
        }
        
        return ""
    }
    
}

