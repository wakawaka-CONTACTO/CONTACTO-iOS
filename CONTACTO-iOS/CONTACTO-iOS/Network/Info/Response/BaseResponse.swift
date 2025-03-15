//
//  BaseResponse.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
}
