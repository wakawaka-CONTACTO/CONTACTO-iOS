//
//  ChatService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol ChatServiceProtocol {
    func chatRoomList(page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[ChatListResponseDTO]>>) -> Void)
    
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void)
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void)
}

final class ChatService: APIRequestLoader<ChatTarget>, ChatServiceProtocol {
    func chatRoomList(page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[ChatListResponseDTO]>>) -> Void) {
        fetchData(target: .chatRoomList(page, size), responseData: PageableResponse<[ChatListResponseDTO]>.self, completion: completion)
    }
        
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void) {
        fetchData(target: .chatRoomMessage(roomId), responseData: ChatRoomResponseDTO.self, completion: completion)
    }
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void) {
        fetchData(target: .chatMessage(roomId, page, size), responseData: PageableResponse<[Message]>.self, completion: completion)
    }
}
