//
//  ErrorResponse.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 12/2/24.
//

import Foundation

struct ErrorResponse<T: Decodable>: Decodable {
    let status: String
    let message: String
    let code: String
    let errors: T?
}
