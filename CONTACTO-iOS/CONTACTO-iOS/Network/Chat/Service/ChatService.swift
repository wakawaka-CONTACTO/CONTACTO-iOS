//
//  ChatService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol ChatServiceProtocol {
    func chatRoomList(cursorId: Int?, cursorCreatedAt: String?, size: Int, completion: @escaping (NetworkResult<ChatListCursorResponse<[ChatListResponseDTO]>>) -> Void)
    
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void)
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void)
    
    func leaveChatRoom(roomId: Int, completion: @escaping (NetworkResult<EmptyResponse>) -> Void)
}

final class ChatService: APIRequestLoader<ChatTarget>, ChatServiceProtocol {
    func chatRoomList(cursorId: Int?, cursorCreatedAt: String?, size: Int, completion: @escaping (NetworkResult<ChatListCursorResponse<[ChatListResponseDTO]>>) -> Void) {
        #if DEBUG
        print("🔄 [Chat] 채팅방 리스트 조회 시작")
        #endif
        fetchData(target: .chatRoomList(cursorId, cursorCreatedAt, size), responseData: ChatListCursorResponse<[ChatListResponseDTO]>.self) { result in
            switch result {
            case .success(let data):
                #if DEBUG
                print("✅ [Chat] 채팅방 리스트 조회 성공 - 데이터 개수: \(data.content.count)")
                #endif
                completion(.success(data))
            case .failure(let error):
                #if DEBUG
                print("❌ [Chat] 채팅방 리스트 조회 실패 - 에러: \(error)")
                #endif
                completion(.failure(error))
            case .pathErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 리스트 조회 실패 - pathErr")
                #endif
                completion(.pathErr)
            case .serverErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 리스트 조회 실패 - serverErr")
                #endif
                completion(.serverErr)
            case .networkErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 리스트 조회 실패 - networkErr")
                #endif
                completion(.networkErr)
            case .requestErr(let data):
                #if DEBUG
                print("❌ [Chat] 채팅방 리스트 조회 실패 - requestErr: \(data)")
                #endif
                completion(.requestErr(data))
            }
        }
    }
    
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void) {
        fetchData(target: .chatRoomMessage(roomId), responseData: ChatRoomResponseDTO.self, completion: completion)
    }
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void) {
        fetchData(target: .chatMessage(roomId, page, size), responseData: PageableResponse<[Message]>.self, completion: completion)
    }
    
    func leaveChatRoom(roomId: Int, completion: @escaping (NetworkResult<EmptyResponse>) -> Void) {
        #if DEBUG
        print("🔄 [Chat] 채팅방 나가기 요청 시작 - roomId: \(roomId)")
        #endif
        
        fetchData(target: .leaveChatRoom(roomId), responseData: EmptyResponse.self) { result in
            switch result {
            case .success(let data):
                #if DEBUG
                print("✅ [Chat] 채팅방 나가기 성공")
                #endif
                completion(.success(data))
            case .failure(let error):
                #if DEBUG
                print("❌ [Chat] 채팅방 나가기 실패 - 에러: \(error)")
                #endif
                completion(.failure(error))
            case .pathErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 나가기 실패 - pathErr")
                #endif
                completion(.pathErr)
            case .serverErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 나가기 실패 - serverErr")
                #endif
                completion(.serverErr)
            case .networkErr:
                #if DEBUG
                print("❌ [Chat] 채팅방 나가기 실패 - networkErr")
                #endif
                completion(.networkErr)
            case .requestErr(let data):
                #if DEBUG
                print("❌ [Chat] 채팅방 나가기 실패 - requestErr: \(data)")
                #endif
                completion(.requestErr(data))
            }
        }
    }
}
