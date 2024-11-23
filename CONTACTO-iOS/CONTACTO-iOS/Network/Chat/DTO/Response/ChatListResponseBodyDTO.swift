//
//  ChatListResponseBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct ChatListResponseBodyDTO: Codable {
    let id: Int
    let title: String
    let participants: [Int]
    let chatRoomThumbnail: String
    let unreadMessageCount: Int
    let latestMessageContent: String?
}
