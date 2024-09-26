//
//  Constants.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

extension API {
    struct Constants {
        static let authorizationApiUrl = "https://api.intra.42.fr/oauth/authorize"
        static let clientID = getValue(from: "ClientID")
        static let clientSecret = getValue(from: "ClientSecret")
        static let tokenAPIURL  = "https://api.intra.42.fr/oauth/token"
        static let redirectURI = "https://www.google.com/"
        static let scopes = "public+projects+profile"
        static let authString = "\(authorizationApiUrl)?response_type=code&client_id=\(clientID)&scopes=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        static let authURL = URL(string: authString)!
    }
    
    protocol EndPoint {
        var path: String { get }
        var authorization: authorization { get }
        var queryItems: [String: String]? { get }
        var url: URL? { get }
    }
    
    enum authorization: String, Codable {
        case user
        case application
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
        print("Couldn't find key '\(key)' in 'API-Info.plist'.")
        return ""
    }
    
    return value
}
