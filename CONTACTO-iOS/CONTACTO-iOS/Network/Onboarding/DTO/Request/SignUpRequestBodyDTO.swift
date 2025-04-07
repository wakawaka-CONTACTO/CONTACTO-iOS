//
//  SignUpRequestBody.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/24/24.
//

import Foundation

struct SignUpRequestBodyDTO: Codable {
    let userSignUpReq: UserSignUpRequest
    let purpose: [Purpose]
    let talent: [TalentType]
    let images: [Data]?
}

struct UserSignUpRequest: Codable {
    let name, email, description, instagramId, password, loginType, nationality: String
    let webUrl: String?
    let firebaseToken: String?
    let deviceId: String?
    let deviceType : String?
}

struct Purpose: Codable {
    let purposeType: Int
}

struct TalentType: Codable {
    let talentType: String
}
