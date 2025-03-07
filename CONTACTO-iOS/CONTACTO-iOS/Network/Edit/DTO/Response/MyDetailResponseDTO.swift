//
//  MyDetailResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct MyDetailResponseDTO: Codable {
    let id: Int
    var username, description, instagramId: String?
    let socialId: Int?
    let loginType: String?
    let email: String
    var webUrl: String?
    let password: String?
    var userPortfolio: UserPortfolio?
    var userPurposes: [Int]
    var userTalents: [UserTalent]
}

struct UserPortfolio: Codable {
    let portfolioId, userId: Int
    var portfolioImageUrl: [String]
}

struct UserTalent: Codable {
    let id, userId: Int?
    var talentType: String
}
