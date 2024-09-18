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
