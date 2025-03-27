//
//  UserInfo.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

struct UserPropertiesInfo {
    let name: String
    let email: String
    let portfolioCount: Int
    let talents: [String]
    let description: String
    let purposes: [String]
    let instagramId: String
    let webUrl: String
    let lastUseDate: Date
    let homeYesCount: Int
    let homeNoCount: Int
    let chatroomCount: Int
    let pushNotificationConsent: Bool
}

struct UserPropertyMetadata {
    let homeYesCount: Int
    let homeNoCount: Int
    let chatroomCount: Int
    let pushNotificationConsent: Bool
}

extension UserPropertiesInfo {
    static func from(_ dto: MyDetailResponseDTO, metadata: UserPropertyMetadata) -> UserPropertiesInfo {
        return UserPropertiesInfo(
            name: dto.username,
            email: dto.email,
            portfolioCount: dto.userPortfolio?.portfolioImageUrl.count ?? 0,
            talents: dto.userTalents.map { $0.talentType },
            description: dto.description ?? "",
            purposes: dto.userPurposes.map { "\($0)" },
            instagramId: dto.instagramId,
            webUrl: dto.webUrl ?? "",
            lastUseDate: Date(),
            homeYesCount: metadata.homeYesCount,
            homeNoCount: metadata.homeNoCount,
            chatroomCount: metadata.chatroomCount,
            pushNotificationConsent: metadata.pushNotificationConsent
        )
    }
}
