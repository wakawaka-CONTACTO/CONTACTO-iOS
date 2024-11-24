//
//  SignUpRequestBody.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/24/24.
//

import Foundation

struct SignUpRequestBodyDTO: Codable {
    let name, email, description, instagramId, password, loginType: String
    let webUrl: String?
    let userPurposes: [Int]
    let userTalents: [String]
    let portfolioImages: [Data]?
}
