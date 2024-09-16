//
//  AuthManager.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let authorizationApiUrl = "https://api.intra.42.fr/oauth/authorize"
        static let clientID = getValue(from: "ClientID")
        static let clientSecret = getValue(from: "ClientSecret")
        static let tokenAPIURL  = "https://api.intra.42.fr/oauth/token"
        static let redirectURI = "https://www.google.com/"
        static let scopes = "public+projects+profile"
        static let access_token = "access_token"
        static let refresh_token = "refresh_token"
        static let expirationDate = "expirationDate"
    }
    
    public var authURL: URL {
        let authorizationUrlString = "\(Constants.authorizationApiUrl)?response_type=code&client_id=\(Constants.clientID)&scopes=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: authorizationUrlString)!
    }
    
    public var signInUrl: URL? {
        let authorizationUrlString = "\(Constants.authorizationApiUrl)?response_type=code&client_id=\(Constants.clientID)&scopes=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: authorizationUrlString)
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: Constants.access_token)
    }
    
    func exchangeCodeForToken(code: String, completion: @escaping (String) -> Void) {
        let tokenURL = URL(string: "https://api.intra.42.fr/oauth/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        let body = "client_id=\(Constants.clientID)&client_secret=\(Constants.clientSecret)&code=\(code)&redirect_uri=https://www.google.com/&grant_type=authorization_code"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    DispatchQueue.main.async {
                        completion(token)
                    }
                }
            } catch {
                print("Error parsing token response")
            }
        }.resume()
    }
    
    
}

func getValue(from key: String) -> String {
    guard let filePath = Bundle.main.path(forResource: "API-Info", ofType: "plist")
    else {
        print("Couldn't find file 'API-Info.plist'.")
        return ""
    }
    
    let plist = NSDictionary(contentsOfFile: filePath)
    
    guard let value = plist?.object(forKey: key) as? String else {
        print("Couldn't find key \(key) in 'API-Info.plist'.")
        return ""
    }
    
    return value
}
