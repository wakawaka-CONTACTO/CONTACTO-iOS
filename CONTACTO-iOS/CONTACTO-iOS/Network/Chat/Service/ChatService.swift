//
//  ChatService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol ChatServiceProtocol {
    func chatRoomList(completion: @escaping (NetworkResult<[ChatListResponseBodyDTO]>) -> Void)
}

final class ChatService: APIRequestLoader<ChatTarget>, ChatServiceProtocol {
    func chatRoomList(completion: @escaping (NetworkResult<[ChatListResponseBodyDTO]>) -> Void) {
        fetchData(target: .chatRoomList, responseData: [ChatListResponseBodyDTO].self, completion: completion)
    }
}
