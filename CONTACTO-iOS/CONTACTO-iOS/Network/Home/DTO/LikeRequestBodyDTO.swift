//
//  LikeRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/12/24.
//

import Foundation

struct LikeRequestBodyDTO: Codable {
    let likedUserId: Int
    let status: String
}

enum LikeStatus: String {
    case like = "LIKE"
    case dislike = "DISLIKE"
}
