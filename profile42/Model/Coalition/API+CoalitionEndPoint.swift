//
//  API+CoalitionEndPoint.swift
//  profile42
//
//  Created by Thibault Giraudon on 26/09/2024.
//

import SwiftUI

extension API {
    enum CoalitionEndPoint: EndPoint {
        case coalition(id: Int)
        
        var authorization: authorization { .user }
        
        var path: String {
            switch self {
            case .coalition(let id):
                return "/v2/users/\(id)/coalitions"
            }
        }
        
        var queryItems: [String: String]? { nil }
        
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

