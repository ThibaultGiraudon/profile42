//
//  Coalition.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

struct Coalition: Codable {
    let id: Int
    let name: String
    let slug: String
    var imageURL: String
    var coverURL: String?
    let color: String
    let score: Int
    let userID: Int
    
    init() {
        self.id = 0
        self.name = ""
        self.slug = ""
        self.imageURL = ""
        self.coverURL = ""
        self.color = ""
        self.score = 0
        self.userID = 0
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.color = try container.decode(String.self, forKey: .color)
        self.score = try container.decode(Int.self, forKey: .score)
        self.coverURL = try container.decode(String?.self, forKey: .coverURL)
        self.userID = try container.decode(Int.self, forKey: .userID)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        
        if self.coverURL == nil {
            self.coverURL = "https://profile.intra.42.fr/assets/background_login-a4e0666f73c02f025f590b474b394fd86e1cae20e95261a6e4862c2d0faa1b04.jpg"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, color, score
        case imageURL = "image_url"
        case coverURL = "cover_url"
        case userID = "user_id"
    }
}

struct CoalitionUser: Codable {
    let id: Int
    let coalitionId: Int
    let userId: Int
    let score: Int
    let rank: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case coalitionId = "coalition_id"
        case userId = "user_id"
        case score
        case rank
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
