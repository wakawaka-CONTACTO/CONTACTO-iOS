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
    var username, description, instagramId: String
    let socialId: Int?
    let loginType, email: String
    var webUrl: String?
    let password: String?
    var userPortfolio: UserPortfolio?
    var userPurposes: [Int]
    var userTalents: [UserTalent]
}

// MARK: - UserPortfolio
struct UserPortfolio: Codable {
    let portfolioId, userId: Int
    var portfolioImages: [String]
}

// MARK: - UserTalent
struct UserTalent: Codable {
    let id, userId: Int
    var talentType: String
}
