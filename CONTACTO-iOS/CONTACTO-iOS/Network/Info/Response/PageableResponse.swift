//
//  PageableResponse.swift
//  CONTACTO-iOS
//
//  Created by 하나 on 3/6/25.
//

import Foundation

struct PageableResponse<T: Codable>: Codable {
    let content: T
    let hasNext: Bool
}
