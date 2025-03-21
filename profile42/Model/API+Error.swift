//
//  API+Error.swift
//  profile42
//
//  Created by Thibault Giraudon on 24/09/2024.
//

import Foundation

extension API {
    enum Error: Swift.Error, LocalizedError {
        case malformed
        case unauthorized
        case forbidden
        case notFound
        case unprocessableEntity
        case internalServerError
        case responseError
        
        var errorDescription: String? {
            switch self {
            case .malformed:
                return "The request is malformed"
            case .unauthorized:
                return "Unauthorized"
            case .forbidden:
                return "Forbidden"
            case .notFound:
                return "Page or resource is not found"
            case .unprocessableEntity:
                return "Unprocessable Entity"
            case .internalServerError:
                return "We have a problem with our server. Please try again later"
            case .responseError:
                return "An error occurred while processing the response"
            }
        }
    }
}
