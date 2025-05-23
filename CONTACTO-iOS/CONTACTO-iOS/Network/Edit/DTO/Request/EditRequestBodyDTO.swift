//
//  EditRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct EditRequestBodyDTO: Codable {
    let username: String
    let email, description, instagramId, password: String
    let webUrl: String?
    let nationality: Nationalities
    let userPurposes: [Int]
    let userTalents: [String]

    let newPortfolioImages: [Data]?
    let newImageKeys: [Int]?

    let existedImageUrl: [String]?
    let existingImageKeys: [Int]?
}
