//
//  PageableRequest.swift
//  CONTACTO-iOS
//
//  Created by 하나 on 3/7/25.
//

import Foundation

struct PageableRequest: Encodable {
    let page: Int
    let size: Int
    let sort: String
}
