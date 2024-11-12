//
//  UserDetailResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

// MARK: - UserDetailResponseDTO
struct UserDetailResponseDTO {
    let id: Int
    let username: String
    let socialID: Int?
    let loginType, email, description, instagramID: String
    let webURL: String?
    let password: String?
    let userPortfolio: UserPortfolio
    let userPurposes: [String]
    let userTalents: [UserTalent]
}

// MARK: - UserPortfolio
struct UserPortfolio {
    let portfolioID, userID: Int
    let portfolioImages: [String]
}

// MARK: - UserTalent
struct UserTalent {
    let id, userID: Int
    let talentType: String
}
