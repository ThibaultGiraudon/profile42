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
    let imageURL: String
    let coverURL: String
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
//        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.coverURL = try container.decode(String.self, forKey: .coverURL)
        self.userID = try container.decode(Int.self, forKey: .userID)
        
        switch self.name {
        case "Water":
            self.imageURL = "drop"
        case "Hearth":
            self.imageURL = "globe"
        case "Wind":
            self.imageURL = "wind"
        case "Fire":
            self.imageURL = "fire"
        default:
            self.imageURL = "fire"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, color, score
        case imageURL = "image_url"
        case coverURL = "cover_url"
        case userID = "user_id"
    }
}
