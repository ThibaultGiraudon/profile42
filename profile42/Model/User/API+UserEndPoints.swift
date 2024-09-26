//
//  API+UserEndPoints.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

extension API {
    enum UserEndPoint: EndPoint {
        case user
        case search(login: String)
        case logtime(id: Int, date: String)
        
        var authorization: authorization { .user }
        
        var path: String {
            switch self {
            case .user:
                return "/v2/me"
            case .search(let login):
                return "/v2/users/\(login)"
            case .logtime(id: let id):
                return "/v2/users/\(id)/locations_stats"
            }
        }
        
        var queryItems: [String: String]? {
            switch self {
            case .logtime(id: _, date: let date):
                return ["begin_at": date]
            default:
                return nil
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
