//
//  SignUpResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/24/24.
//

import Foundation

struct SignUpResponseDTO: Codable {
    let userId: Int
    let accessToken: String
    let refreshToken: String
}
