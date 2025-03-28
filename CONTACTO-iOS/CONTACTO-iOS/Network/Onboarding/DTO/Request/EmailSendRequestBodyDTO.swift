//
//  EmailSendRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/12/24.
//

import Foundation

enum EmailSendPurpose: String, Codable {
    case signup = "SIGNUP"
    case reset = "RESET"
}

struct EmailSendRequestBodyDTO: Codable {
    let email: String
    let purpose: EmailSendPurpose
}
