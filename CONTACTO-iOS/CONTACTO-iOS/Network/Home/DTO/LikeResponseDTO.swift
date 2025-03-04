//
//  LikeResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/12/24.
//

import Foundation

struct LikeResponseDTO: Codable {
    let userPortfolios: [PortfoliosResponseDTO]?
    let chatRoomId: Int?
    let matched: Bool
}
