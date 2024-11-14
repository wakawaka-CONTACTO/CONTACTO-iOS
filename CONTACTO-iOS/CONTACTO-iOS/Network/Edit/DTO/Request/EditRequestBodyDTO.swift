//
//  EditRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct EditRequestBodyDTO: Codable {
    let email, descriotion, instagramId, password, userTalents: String
    let webUrl: String?
    let userPurposes: [Int]
//    let portfolioImages: //multipart
}
