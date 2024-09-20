//
//  Evaluation.swift
//  profile42
//
//  Created by Thibault Giraudon on 20/09/2024.
//


import Foundation

struct Evaluation: Codable {
    let id: Int
    let scaleID: Int
    let comment: String?
    let createdAt: String
    let updatedAt: String
    let feedback: String?
    let finalMark: Int?
    let flag: Flag
    let beginAt: String
    let correcteds: [Corrected]
    let corrector: Corrector
    let truant: Truant
    let filledAt: String?
    let questionsWithAnswers: [QuestionWithAnswer]
    let scale: Scale
    let team: Team
    let feedbacks: [Feedback]
    
    init() {
        self.id = 0
        self.scaleID = 0
        self.comment = ""
        self.createdAt = ""
        self.updatedAt = ""
        self.feedback = ""
        self.finalMark = 0
        self.flag = Flag(id: 0, name: "", positive: true, icon: "", createdAt: "", updatedAt: "")
        self.beginAt = ""
        self.correcteds = []
        self.corrector = Corrector(id: 0, login: "", url: "")
        self.truant = Truant(id: 0, login: "", url: "")
        self.filledAt = ""
        self.questionsWithAnswers = []
        self.scale = Scale()
        self.team = Team()
        self.feedbacks = []
    }

    enum CodingKeys: String, CodingKey {
        case id
        case scaleID = "scale_id"
        case comment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case feedback
        case finalMark = "final_mark"
        case flag
        case beginAt = "begin_at"
        case correcteds
        case corrector
        case truant
        case filledAt = "filled_at"
        case questionsWithAnswers = "questions_with_answers"
        case scale
        case team
        case feedbacks
    }
}

struct Flag: Codable {
    let id: Int
    let name: String
    let positive: Bool
    let icon: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case positive
        case icon
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Corrected: Codable {
    let id: Int
    let login: String
    let url: String
}

struct Corrector: Codable {
    let id: Int
    let login: String
    let url: String
}

struct Truant: Codable {
    let id: Int?
    let login: String?
    let url: String?
}

struct QuestionWithAnswer: Codable {}

struct Scale: Codable {
    let id: Int
    let evaluationID: Int
    let name: String
    let isPrimary: Bool
    let comment: String
    let introductionMd: String
    let disclaimerMd: String
    let guidelinesMd: String
    let createdAt: String
    let correctionNumber: Int
    let duration: Int
    let manualSubscription: Bool
    let languages: [Language]
    let flags: [Flag]
    let free: Bool
    
    init() {
        self.id = 0
        self.evaluationID = 0
        self.name = ""
        self.isPrimary = false
        self.comment = ""
        self.introductionMd = ""
        self.disclaimerMd = ""
        self.guidelinesMd = ""
        self.createdAt = ""
        self.correctionNumber = 0
        self.duration = 0
        self.manualSubscription = false
        self.languages = []
        self.flags = []
        self.free = false
    }

    enum CodingKeys: String, CodingKey {
        case id
        case evaluationID = "evaluation_id"
        case name
        case isPrimary = "is_primary"
        case comment
        case introductionMd = "introduction_md"
        case disclaimerMd = "disclaimer_md"
        case guidelinesMd = "guidelines_md"
        case createdAt = "created_at"
        case correctionNumber = "correction_number"
        case duration
        case manualSubscription = "manual_subscription"
        case languages
        case flags
        case free
    }
}

struct Language: Codable {
    let id: Int
    let name: String
    let identifier: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case identifier
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Team: Codable {
    let id: Int
    let name: String
    let url: String
    let finalMark: Int
    let projectID: Int
    let createdAt: String
    let updatedAt: String
    let status: String
    let terminatingAt: String?
    let users: [UserTeam]
    let locked: Bool
    let validated: Bool
    let closed: Bool
    let repoURL: String
    let repoUUID: String
    let lockedAt: String
    let closedAt: String
    let projectSessionID: Int
    let projectGitlabPath: String
    
    init() {
        self.id = 0
        self.name = ""
        self.url = ""
        self.finalMark = 0
        self.projectID = 0
        self.createdAt = ""
        self.updatedAt = ""
        self.status = ""
        self.terminatingAt = ""
        self.users = []
        self.locked = false
        self.validated = false
        self.closed = false
        self.repoURL = ""
        self.repoUUID = ""
        self.lockedAt = ""
        self.closedAt = ""
        self.projectSessionID = 0
        self.projectGitlabPath = ""
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case finalMark = "final_mark"
        case projectID = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status
        case terminatingAt = "terminating_at"
        case users
        case locked = "locked?"
        case validated = "validated?"
        case closed = "closed?"
        case repoURL = "repo_url"
        case repoUUID = "repo_uuid"
        case lockedAt = "locked_at"
        case closedAt = "closed_at"
        case projectSessionID = "project_session_id"
        case projectGitlabPath = "project_gitlab_path"
    }
}

struct UserTeam: Codable {
    let id: Int
    let login: String
    let url: String
    let leader: Bool
    let occurrence: Int
    let validated: Bool
    let projectsUserID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case url
        case leader
        case occurrence
        case validated
        case projectsUserID = "projects_user_id"
    }
}

struct Feedback: Codable {
    let id: Int
    let user: FeedbackUser
    let feedbackableType: String
    let feedbackableID: Int
    let comment: String
    let rating: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case user
        case feedbackableType = "feedbackable_type"
        case feedbackableID = "feedbackable_id"
        case comment
        case rating
        case createdAt = "created_at"
    }
}

struct FeedbackUser: Codable {
    let login: String
    let id: Int
    let url: String
}
