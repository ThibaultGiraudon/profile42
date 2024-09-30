//
//  API.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

struct Token: Codable {
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct ApplicationToken: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

class API: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var token: Token = Token(accessToken: "", refreshToken: "") {
        didSet {
            do {
                let data = try JSONEncoder().encode(token)
                UserDefaults.standard.set(data, forKey: "token")
            } catch {
                print(error)
            }
        }
    }
    @Published var applicationToken: String = "" {
        didSet {
            do {
                let data = try JSONEncoder().encode(applicationToken)
                UserDefaults.standard.set(data, forKey: "applicationToken")
            } catch {
                print(error)
            }
        }
    }
    @Published var alertTitle: String = ""
    @Published var showAlert: Bool = false
    @Published var user = User()
    @Published var coalitions = [Coalition]()
    @Published var currentCoalition = Coalition()
    @Published var currentCursus = CursusUser()
    @Published var currentCampus = Campus()
    @Published var isLoading = false
    @Published var locationStats = [String: String]()
    @Published var finishedProjects = [ProjectUser]()
    @Published var currentProjects = [ProjectUser]()
    @Published var evaluationLogs = [Correction]()
    @Published var events = [Event]()
    @Published var history = [User]()  {
        didSet {
            do {
                let data = try JSONEncoder().encode(history)
                UserDefaults.standard.set(data, forKey: "history")
            } catch {
                print(error)
            }
        }
    }
    @Published var evaluations = [Evaluation]()
    @Published var selectedUser = User()
    @Published var selectedProject = ProjectUser()
    @Published var selectedEvent = Event()
    @Published var activeTab: Tab = .profile
    @Published var navHistory: [Tab] = [.profile]
    @Published var userHistory: [User] = []
    @Published var failedCount: Int = 0
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "token") {
            do {
                token = try JSONDecoder().decode(Token.self, from: data)
            } catch {
                print(error)
            }
        } else {
            token = Token(accessToken: "", refreshToken: "")
        }
        if let data = UserDefaults.standard.data(forKey: "applicationToken") {
            do {
                applicationToken = try JSONDecoder().decode(String.self, from: data)
            } catch {
                print(error)
            }
        } else {
            applicationToken = ""
        }
        
        if let data = UserDefaults.standard.data(forKey: "history") {
            do {
                history = try JSONDecoder().decode([User].self, from: data)
            } catch {
                print(error)
            }
        } else {
            history = []
        }
    }
    
    func getEvaluations(for id: Int) -> [Evaluation] {
        var evaluations: [Evaluation] = []
        
        self.evaluations.forEach { evaluation in
            if evaluation.team.id == id {
                evaluations.append(evaluation)
            }
        }
        
        return evaluations
    }
    
    func getFinihedProjects() -> [ProjectUser] {
        user.projectsUsers.filter { $0.validated != nil }
    }
    
    func getCurrentProjects() -> [ProjectUser] {
        user.projectsUsers.filter { $0.validated == nil }
    }

    func getCurrentCampus(from allCampus: [Campus]) -> Campus {
        let lastCampus = user.campusUsers.first(where: {$0.isPrimary} )!
        
        return allCampus.first(where: {$0.id == lastCampus.campusID})!
    }
    
    func getCurrentCursus(from allCursus: [CursusUser]) -> CursusUser {
        var lastCursus = CursusUser()

        for cursusUser in allCursus {
            if cursusUser.beginAt > lastCursus.beginAt {
                lastCursus = cursusUser
            }
        }
        return lastCursus
    }
    
    @MainActor
    func fetchData<T: Decodable>(_ endpoint: API.EndPoint) async throws -> T {
        guard let apiURL = endpoint.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue("Bearer \(endpoint.authorization == .application ? applicationToken : token.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print(apiURL)
            switch (response as? HTTPURLResponse)?.statusCode {
            case 400:
                throw API.Error.malformed
            case 401:
                failedCount += 1
                if failedCount >= 3 {
                    throw API.Error.unauthorized
                } else {
                    token = try await getToken(endpoint: API.AuthEndPoint.refreshToken(token: token.refreshToken))
                    let appToken: ApplicationToken = try await getToken(endpoint: API.AuthEndPoint.application)
                    applicationToken = appToken.accessToken
                    return try await fetchData(endpoint)
                }
            case 403:
                throw API.Error.forbidden
            case 404:
                throw API.Error.notFound
            case 422:
                throw API.Error.unprocessableEntity
            case 429:
                try await Task.sleep(for: .seconds(1))
                return try await fetchData(endpoint)
            case 500:
                throw API.Error.internalServerError
            default:
                throw API.Error.internalServerError
            }
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            failedCount = 0
            return decoded
        } catch {
            print(error)
            throw API.Error.responseError
        }
    }
    
    @MainActor
    func getToken<T: Decodable>(endpoint: API.AuthEndPoint) async throws -> T {
        guard let tokenURL = endpoint.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            switch (response as? HTTPURLResponse)?.statusCode {
            case 400:
                throw API.Error.malformed
            case 401:
                failedCount += 1
                if failedCount >= 3 {
                    throw API.Error.unauthorized
                } else {
                    token = try await getToken(endpoint: API.AuthEndPoint.refreshToken(token: token.refreshToken))
                    let appToken: ApplicationToken = try await getToken(endpoint: API.AuthEndPoint.application)
                    applicationToken = appToken.accessToken
                    return try await fetchData(endpoint)
                }
            case 403:
                throw API.Error.forbidden
            case 404:
                throw API.Error.notFound
            case 422:
                throw API.Error.unprocessableEntity
            case 429:
                try await Task.sleep(for: .seconds(1))
                return try await fetchData(endpoint)
            case 500:
                throw API.Error.internalServerError
            default:
                throw API.Error.internalServerError
            }
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    @MainActor
    func logIn() async throws {
        self.isLoading = true
        let user: User = try await self.fetchData(UserEndPoint.user)
        self.user = user
        self.currentCursus = self.getCurrentCursus(from: user.cursusUsers)
        self.currentCampus = self.getCurrentCampus(from: user.campus)
        self.events = try await self.fetchData(EventEndPoints.events(campusID: self.currentCampus.id, cursusID: self.currentCursus.cursusID))
        self.coalitions = try await self.fetchData(CoalitionEndPoint.coalition(id: user.id))
        self.isLoggedIn = true
        self.isLoading = false
    }
    
    func logOut() {
        isLoggedIn = false
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        self.user = User()
        self.token = Token(accessToken: "", refreshToken: "")
        self.applicationToken = ""
        self.history = []
    }
    
}


