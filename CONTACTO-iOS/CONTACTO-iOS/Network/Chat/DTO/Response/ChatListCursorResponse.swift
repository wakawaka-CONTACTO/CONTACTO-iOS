//
//  ChatListCursorResponse.swift
//  CONTACTO-iOS
//
//  Created by hana on 5/28/25.
//

import Foundation

struct ChatListCursorResponse<T: Codable>: Codable {
    let content: T
    let hasNext: Bool
    let nextCursorId: Int?
    let nextCursorCreatedAt: String?
    
    init(content: T, hasNext: Bool, nextCursorId: Int?, nextCursorCreatedAt: String?) {
        self.content = content
        self.hasNext = hasNext
        self.nextCursorId = nextCursorId
        self.nextCursorCreatedAt = nextCursorCreatedAt
    }
    
    static func of<T: Codable>(content: T, hasNext: Bool, nextCursorId: Int?, nextCursorCreatedAt: String?) -> ChatListCursorResponse<T> {
        return ChatListCursorResponse<T>(content: content, hasNext: hasNext, nextCursorId: nextCursorId, nextCursorCreatedAt: nextCursorCreatedAt)
    }
}
