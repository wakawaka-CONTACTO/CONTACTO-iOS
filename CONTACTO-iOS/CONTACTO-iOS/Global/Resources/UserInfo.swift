//
//  UserInfo.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/24/24.
//

import Foundation

final class UserInfo {
    static let shared = UserInfo()
    
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var description: String = ""
    var instagramId: String = ""
    var loginType: String = ""
    var webUrl: String?
    var userPurposes: [Int] = []
    var userTalents: [String] = []
    var portfolioImageUrl: [Data] = []
    
    
    private init() {}
}

func updateUserInfo(_ data: MyDetailResponseDTO) {
    var userType = ""
    
    UserInfo.shared.email = data.email
//    UserInfo.shared.password = data.password
    UserInfo.shared.name = data.username
    UserInfo.shared.description = data.description
    UserInfo.shared.instagramId = data.instagramId
    UserInfo.shared.loginType = data.loginType
    UserInfo.shared.webUrl = data.webUrl
    UserInfo.shared.userPurposes = data.userPurposes
    UserInfo.shared.userTalents = data.userTalents.map { $0.talentType }
//    UserInfo.shared.portfolioImageUrl = data.portfolioImageUrl
}

