//
//  AuthEndPoint.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

extension API {
    enum AuthEndPoint: EndPoint {
        case authorize
        case user(code: String)
        case application
        
        var authorization: authorization { .user }
        
        var path: String {
            switch self {
            case .authorize:
                return "/oauth/authorize"
            case .user(_):
                return "/oauth/token"
            case .application:
                return "/oauth/token"
            }
        }
        
        var queryItems: [String: String]? {
            switch self {
            case .authorize:
                return [
                    "response_type": "code",
                    "client_id": API.Constants.clientID,
                    "scope": "public+projects+profile",
                    "redirect_uri": API.Constants.redirectURI,
                ]
            case .user(let code):
                return [
                    "client_id": API.Constants.clientID,
                    "client_secret": API.Constants.clientSecret,
                    "code": code,
                    "redirect_uri": API.Constants.redirectURI,
                    "grant_type": "authorization_code",
                ]
            case .application:
                return [
                    "grant_type": "client_credentials",
                    "client_id": API.Constants.clientID,
                    "client_secret": API.Constants.clientSecret,
                    "scope": "public+projects+profile",
                ]
            }
        }
        
        var url: URL? {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.intra.42.fr"
            components.path = path
            
            var localQueryItems: [URLQueryItem] = []
            
            queryItems?.forEach {
                localQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
            }
            
            components.queryItems = localQueryItems
            
            return components.url
        }
    }
}
