//
//  EmailCheckRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/12/24.
//

import Foundation

struct EmailCheckRequestBodyDTO: Codable {
    let email: String
    let authCode: String
}
