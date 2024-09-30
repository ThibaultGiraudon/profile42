//
//  API+ExamEndPoint.swift
//  profile42
//
//  Created by Thibault Giraudon on 28/09/2024.
//


import SwiftUI

extension API {
    enum ExamEndPoint: EndPoint {
        case exam(id: Int)
        
        var authorization: authorization { .user }
        
        var path: String {
            switch self {
            case .exam(let id):
                return "/v2/users/\(id)/exams"
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
