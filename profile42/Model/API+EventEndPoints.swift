//
//  API+EventEndPoints.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import Foundation
import SwiftUI

extension API {
    enum EventEndPoints: EndPoint {
        case events(campusID: Int, cursusID: Int)
        
        var authorization: API.authorization { .user }
        
        var path: String {
            switch self {
            case .events(let campusID, let cursusID):
                return "/v2/campus/\(campusID)/cursus/\(cursusID)/events"
            }
        }
        
        var queryItems: [String : String]? {
            switch self {
            case .events:
                ["filter[future]": "true",
                 "sort": "-begin_at"]
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
