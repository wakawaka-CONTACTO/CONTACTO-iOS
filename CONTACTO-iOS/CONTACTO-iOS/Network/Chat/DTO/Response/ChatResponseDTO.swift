//
//  ChatResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 12/1/24.
//

import Foundation

struct ChatResponseDTO: Codable {
    let id: String
    let content: String
    let senderId: String
    let sendedId: String
    let chatRoomId: String
    let createAt: String
}
