//
//  ChatRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct ChatRequestBodyDTO: Codable {
    let content: String
    let senderId: String
    let sendedId: String
    let chatRoomId: String
    let createAt: String
}
