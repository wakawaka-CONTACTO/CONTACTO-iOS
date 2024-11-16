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
    let socialId: Int?
    let loginType, email, description, instagramId: String
    let webUrl: String?
    let password: String?
    let userPortfolio: UserPortfolio
    let userPurposes: [Int]
    let userTalents: [UserTalent]
}

// MARK: - UserPortfolio
struct UserPortfolio: Codable {
    let portfolioId, userId: Int
    let portfolioImages: [String]
}

// MARK: - UserTalent
struct UserTalent: Codable {
    let id, userId: Int
    let talentType: String
}
