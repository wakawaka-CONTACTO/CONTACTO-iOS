//
//  MyDetailResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

// MARK: - MyDetailResponseDTO
struct MyDetailResponseDTO: Codable {
    let id: Int
    let username: String
    let socialID: Int?
    let loginType, email, description, instagramID: String
    let webURL: String?
    let password: String?
    let userPortfolio: UserPortfolio
    let userPurposes: [Int]
    let userTalents: [UserTalent]
}

// MARK: - UserPortfolio
struct UserPortfolio: Codable {
    let portfolioID, userID: Int
    let portfolioImages: [String]
}

// MARK: - UserTalent
struct UserTalent: Codable {
    let id, userID: Int
    let talentType: String
}
