//
//  ChatListCursorRequest.swift
//  CONTACTO-iOS
//
//  Created by hana on 5/28/25.
//

import Foundation

struct ChatListCursorRequest: Encodable {
    let cursorId: Int?
    let cursorCreatedAt: String?
    let size: Int
    
    init(cursorId: Int?, cursorCreatedAt: String?, size: Int) {
        self.cursorId = cursorId
        self.cursorCreatedAt = cursorCreatedAt
        self.size = size
    }
    
    static func of(cursorId: Int?, cursorCreatedAt: String?, size: Int) -> ChatListCursorRequest {
        return ChatListCursorRequest(cursorId: cursorId, cursorCreatedAt: cursorCreatedAt, size: size)
    }
}
