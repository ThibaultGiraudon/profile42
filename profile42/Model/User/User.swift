//
//  User.swift
//  profile42
//
//  Created by Thibault Giraudon on 16/09/2024.
//

import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let login: String
    let firstName: String
    let lastName: String
    let usualFullName: String
    let usualFirstName: String?
    let url: String
    let phone: String?
    let displayName: String
    let kind: String
    let image: SImage
    let isStaff: Bool
    let correctionPoint: Int
    let poolMonth: String
    let poolYear: String
    let location: String?
    let wallet: Int
    let anonymizeDate: String
    let dataErasureDate: String?
    let isAlumni: Bool
    let isActive: Bool
    let groups: [String]
    let cursusUsers: [CursusUser]
    let projectsUsers: [ProjectUser]
    let languagesUsers: [LanguageUser]
    var achievements: [Achievement]
    let titles: [String]
    let titlesUsers: [String]
    let partnerships: [Partnership]
    let patroned: [Patron]
    let patroning: [Patron]
    let expertisesUsers: [ExpertiseUser]
    let roles: [String]
    let campus: [Campus]
    let campusUsers: [CampusUser]
    
    init() {
        self.id = 0
        self.email = ""
        self.login = ""
        self.firstName = ""
        self.lastName = ""
        self.usualFullName = ""
        self.usualFirstName = ""
        self.url = ""
        self.phone = ""
        self.displayName = ""
        self.kind = ""
        self.image = SImage()
        self.isStaff = false
        self.correctionPoint = 0
        self.poolMonth = ""
        self.poolYear = ""
        self.location = ""
        self.wallet = 0
        self.anonymizeDate = ""
        self.dataErasureDate = ""
        self.isAlumni = false
        self.isActive = false
        self.groups = []
        self.cursusUsers = []
        self.projectsUsers = []
        self.languagesUsers = []
        self.achievements = []
        self.titles = []
        self.titlesUsers = []
        self.partnerships = []
        self.patroned = []
        self.patroning = []
        self.expertisesUsers = []
        self.roles = []
        self.campus = []
        self.campusUsers = []
    }

    enum CodingKeys: String, CodingKey {
        case id, email, login, url, phone, kind, image, wallet, location, groups, achievements, titles, partnerships, roles, campus
        case firstName = "first_name"
        case lastName = "last_name"
        case usualFullName = "usual_full_name"
        case usualFirstName = "usual_first_name"
        case displayName = "displayname"
        case isStaff = "staff?"
        case correctionPoint = "correction_point"
        case poolMonth = "pool_month"
        case poolYear = "pool_year"
        case anonymizeDate = "anonymize_date"
        case dataErasureDate = "data_erasure_date"
        case isAlumni = "alumni?"
        case isActive = "active?"
        case cursusUsers = "cursus_users"
        case projectsUsers = "projects_users"
        case languagesUsers = "languages_users"
        case titlesUsers = "titles_users"
        case patroned, patroning
        case expertisesUsers = "expertises_users"
        case campusUsers = "campus_users"
    }
}

struct SImage: Codable {
    let link: String
    let versions: Versions

    struct Versions: Codable {
        let large: String
        let medium: String
        let small: String
        let micro: String
        
        init() {
            self.large = ""
            self.medium = ""
            self.small = ""
            self.micro = ""
        }
    }
    
    init() {
        self.link = ""
        self.versions = Versions()
    }
}

struct CursusUser: Codable {
    let id: Int
    let beginAt: String
    let endAt: String?
    let grade: String?
    let level: Double
    let skills: [Skills]
    let cursusID: Int
    let hasCoalition: Bool
    let createdAt: String
    let updatedAt: String
    let blackholedAt: String?
    let user: UserRef
    let cursus: Cursus
    
    init() {
        self.id = 0
        self.beginAt = ""
        self.endAt = ""
        self.grade = ""
        self.level = 0.0
        self.skills = []
        self.cursusID = 0
        self.hasCoalition = false
        self.createdAt = ""
        self.updatedAt = ""
        self.blackholedAt = ""
        self.user = UserRef(id: 0, login: "", url: "")
        self.cursus = Cursus(id: 0, createdAt: "", name: "", slug: "")
    }

    enum CodingKeys: String, CodingKey {
        case id, grade, level, skills, user, cursus
        case beginAt = "begin_at"
        case endAt = "end_at"
        case cursusID = "cursus_id"
        case hasCoalition = "has_coalition"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blackholedAt = "blackholed_at"
    }
    
    struct Skills: Codable, Identifiable  {
        let id: Int
        let name: String
        let level: Double
    }

    struct UserRef: Codable{
        let id: Int
        let login: String
        let url: String
    }

    struct Cursus: Codable {
        let id: Int
        let createdAt: String
        let name: String
        let slug: String

        enum CodingKeys: String, CodingKey {
            case id, name, slug
            case createdAt = "created_at"
        }
    }
}

struct LanguageUser: Codable {
    let id: Int
    let languageID: Int
    let userID: Int
    let position: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, position
        case languageID = "language_id"
        case userID = "user_id"
        case createdAt = "created_at"
    }
}

struct ProjectUser: Codable, Identifiable, Hashable {
    static func == (lhs: ProjectUser, rhs: ProjectUser) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
    
    let id: Int
    let occurrence: Int
    let finalMark: Int?
    let status: String
    let validated: Bool?
    let currentTeamID: Int?
    let project: Project
    let cursusIDs: [Int]
    let markedAt: String?
    let marked: Bool
    let retriableAt: String?
    let createdAt: String
    let updatedAt: String
    
    init() {
        self.id = 0
        self.occurrence = 0
        self.finalMark = nil
        self.status = ""
        self.validated = nil
        self.currentTeamID = nil
        self.project = .init(id: 0, name: "", slug: "", parentID: nil)
        self.cursusIDs = []
        self.markedAt = nil
        self.marked = false
        self.retriableAt = nil
        self.createdAt = ""
        self.updatedAt = ""
    }

    enum CodingKeys: String, CodingKey {
        case id, occurrence, finalMark = "final_mark", status, validated = "validated?", currentTeamID = "current_team_id", project, cursusIDs = "cursus_ids", markedAt = "marked_at", marked, retriableAt = "retriable_at", createdAt = "created_at", updatedAt = "updated_at"
    }

    struct Project: Codable {
        let id: Int
        let name: String
        let slug: String
        let parentID: Int?

        enum CodingKeys: String, CodingKey {
            case id, name, slug
            case parentID = "parent_id"
        }
    }
}


struct Achievement: Codable {
    let id: Int
    let name: String
    let description: String
    let tier: String
    let kind: String
    let visible: Bool
    let image: String
    let nbrOfSuccess: Int?
    let usersURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, tier, kind, visible, image
        case nbrOfSuccess = "nbr_of_success"
        case usersURL = "users_url"
    }
}

struct Partnership: Codable {
    let id: Int
    let name: String
    let slug: String
    let difficulty: Int
    let url: String
    let partnershipsUsersURL: String
    let partnershipsSkills: [PartnershipSkill]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case difficulty
        case url
        case partnershipsUsersURL = "partnerships_users_url"
        case partnershipsSkills = "partnerships_skills"
    }
}

struct PartnershipSkill: Codable {
    let id: Int
    let partnershipID: Int
    let skillID: Int
    let value: Double
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case partnershipID = "partnership_id"
        case skillID = "skill_id"
        case value
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Patron: Codable {
    let id: Int
    let userID: Int
    let godfatherID: Int
    let ongoing: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, ongoing
        case userID = "user_id"
        case godfatherID = "godfather_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ExpertiseUser: Codable {
    let id: Int
    let expertiseID: Int
    let interested: Bool
    let value: Int
    let contactMe: Bool
    let createdAt: String
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case id, interested, value
        case expertiseID = "expertise_id"
        case contactMe = "contact_me"
        case createdAt = "created_at"
        case userID = "user_id"
    }
}

struct Campus: Codable {
    let id: Int
    let name: String
    let timeZone: String
    let language: Language
    let usersCount: Int
    let vogsphereID: Int
    
    init() {
        self.id = 0
        self.name = ""
        self.timeZone = ""
        self.language = .init(id: 0, name: "", identifier: "", createdAt: "", updatedAt: "")
        self.usersCount = 0
        self.vogsphereID = 0
    }

    enum CodingKeys: String, CodingKey {
        case id, name, language
        case timeZone = "time_zone"
        case usersCount = "users_count"
        case vogsphereID = "vogsphere_id"
    }

    struct Language: Codable {
        let id: Int
        let name: String
        let identifier: String
        let createdAt: String
        let updatedAt: String

        enum CodingKeys: String, CodingKey {
            case id, name, identifier
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
}

struct CampusUser: Codable {
    let id: Int
    let userID: Int
    let campusID: Int
    let isPrimary: Bool
    
    init() {
        self.id = 0
        self.userID = 0
        self.campusID = 0
        self.isPrimary = false
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case campusID = "campus_id"
        case isPrimary = "is_primary"
    }
}

