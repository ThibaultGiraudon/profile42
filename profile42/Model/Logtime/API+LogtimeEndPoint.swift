//
//  API+LogtimeEndPoint.swift
//  profile42
//
//  Created by Thibault Giraudon on 17/09/2024.
//

import SwiftUI

extension API {
    enum LogtimeEndPoint: EndPoint {
        case location(id: Int, startDate: String)
        
        var authorization: authorization { .application }
        
        var path: String {
            switch self {
            case .location(let id, _):
                return "/v2/users/\(id)/locations_stats"
            }
        }
        
        var queryItems: [String: String]? {
            switch self {
            case .location(_, let startDate):
                return ["begin_at": String(startDate.prefix(10))]
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
