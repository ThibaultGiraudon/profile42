//
//  Correction.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//

import Foundation

struct Correction: Codable, Identifiable {
    var id: Int
    var scaleTeamId: Int?
    var reason: String
    var sum: Int
    var total: Int
    var createdAt: String
    var updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case scaleTeamId = "scale_team_id"
        case reason
        case sum
        case total
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
