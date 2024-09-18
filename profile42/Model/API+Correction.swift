//
//  API+Correction.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import SwiftUI

extension API {
    enum CorrectionEndpoint: EndPoint {
        case correction(id: String)
        
        var authorization: authorization { .user }
        
        var path: String {
            switch self {
            case .correction(id: let id):
                return "/v2/users/\(id)/correction_point_historics"
            }
        }
        
        var queryItems: [String: String]? {
            switch self {
            case .correction:
                ["sort": "-created_at"]
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
