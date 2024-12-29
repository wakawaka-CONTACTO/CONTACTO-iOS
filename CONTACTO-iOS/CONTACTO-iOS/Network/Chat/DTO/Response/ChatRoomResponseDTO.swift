//
//  ChatRoomResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/23/24.
//

import Foundation

struct ChatRoomResponseDTO: Codable {
    let id: Int
    let title: String
    let messages: [Message]
    let participants: [Int]
    let chatRoomThumbnail: String?
}

struct Message: Codable {
    let content: String
    let senderId: Int
    let createdAt: String
    let readStatus: Bool
}
