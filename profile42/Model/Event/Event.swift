//
//  Event.swift
//  profile42
//
//  Created by Thibault Giraudon on 18/09/2024.
//


import Foundation

struct Event: Codable, Identifiable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let name: String
    let description: String
    let location: String
    let kind: String
    let maxPeople: Int?
    let nbrSubscribers: Int
    let beginAt: String
    let endAt: String
    let campusIDs: [Int]
    let cursusIDs: [Int]
    let themes: [Theme]
    let waitlist: Waitlist?
    let prohibitionOfCancellation: Int?
    let createdAt: String
    let updatedAt: String
    
    init() {
        self.id = 0
        self.name = ""
        self.description = ""
        self.location = ""
        self.kind = ""
        self.maxPeople = nil
        self.nbrSubscribers = 0
        self.beginAt = ""
        self.endAt = ""
        self.campusIDs = []
        self.cursusIDs = []
        self.themes = []
        self.waitlist = nil
        self.prohibitionOfCancellation = nil
        self.createdAt = ""
        self.updatedAt = ""
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, location, kind
        case maxPeople = "max_people"
        case nbrSubscribers = "nbr_subscribers"
        case beginAt = "begin_at"
        case endAt = "end_at"
        case campusIDs = "campus_ids"
        case cursusIDs = "cursus_ids"
        case themes
        case waitlist
        case prohibitionOfCancellation = "prohibition_of_cancellation"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Theme: Codable {
    let createdAt: String
    let id: Int
    let name: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id, name
        case updatedAt = "updated_at"
    }
}

struct Waitlist: Codable {
    let createdAt: String
    let id: Int
    let updatedAt: String
    let waitlistableID: Int
    let waitlistableType: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case updatedAt = "updated_at"
        case waitlistableID = "waitlistable_id"
        case waitlistableType = "waitlistable_type"
    }
}
