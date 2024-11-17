//
//  EditRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct EditRequestBodyDTO: Codable {
    let username, email, description, instagramId, password: String
    let webUrl: String?
    let userPurposes: [Int]
    let userTalents: [String]
    let portfolioImages: [Data]?
}
