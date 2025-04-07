//
//  LoginRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct LoginRequestBodyDTO: Codable {
    let email: String
    let password: String
    let firebaseToken: String?
    let deviceId: String?
    let deviceType : String?
}
