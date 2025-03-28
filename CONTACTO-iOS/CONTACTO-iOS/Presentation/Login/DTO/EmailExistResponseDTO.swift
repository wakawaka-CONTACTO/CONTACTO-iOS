//
//  EmailExistResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/28/25.
//

import Foundation

public struct EmailExistResponseDTO: Decodable {
    let id: Int?
    let description: String?
    let nationality: String?
    let userPurposes: [String]?
    let loginType: String?
    let password: String?
    let instagramId: String?
    let username: String?
    let userPortfolio: [String]?
    let userTalents: [String]?
    let webUrl: String?
    let email: String?
}
