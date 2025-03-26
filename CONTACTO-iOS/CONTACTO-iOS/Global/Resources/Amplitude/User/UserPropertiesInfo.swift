//
//  UserInfo.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

struct UserPropertiesInfo {

    let userId: Int
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
    let userId: Int
    let lastUseDate: Date
    let homeYesCount: Int
    let homeNoCount: Int
    let chatroomCount: Int
    let pushNotificationConsent: Bool
}

extension UserPropertiesInfo {
    static func from(_ userInfo: UserInfo, metadata: UserPropertyMetadata) -> UserPropertiesInfo {
        return UserPropertiesInfo(
            userId: metadata.userId,
            name: userInfo.name,
            email: userInfo.email,
            portfolioCount: userInfo.portfolioImageUrl.count,
            talents: userInfo.userTalents,
            description: userInfo.description,
            purposes: userInfo.userPurposes.map { "\($0)" },
            instagramId: userInfo.instagramId,
            webUrl: userInfo.webUrl ?? "",
            lastUseDate: metadata.lastUseDate,
            homeYesCount: metadata.homeYesCount,
            homeNoCount: metadata.homeNoCount,
            chatroomCount: metadata.chatroomCount,
            pushNotificationConsent: metadata.pushNotificationConsent
        )
    }
}
