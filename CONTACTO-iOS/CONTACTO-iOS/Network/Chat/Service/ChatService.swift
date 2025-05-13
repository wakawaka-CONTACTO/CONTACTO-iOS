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
    
    func leaveChatRoom(roomId: Int, completion: @escaping (NetworkResult<ChatLeaveResponseDTO>) -> Void)
}

final class ChatService: APIRequestLoader<ChatTarget>, ChatServiceProtocol {
    func chatRoomList(page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[ChatListResponseDTO]>>) -> Void) {
        let startTime = Date()
        #if DEBUG
        print("🔄 [Chat] 채팅방 리스트 조회 시작 - 시간: \(startTime)")
        #endif
        
        fetchData(target: .chatRoomList(page, size), responseData: PageableResponse<[ChatListResponseDTO]>.self) { result in
            let responseTime = Date()
            #if DEBUG
            print("📥 [Chat] API 응답 수신 - 시간: \(responseTime)")
            print("⏱️ [Chat] API 응답 소요시간: \(responseTime.timeIntervalSince(startTime))초")
            #endif
            
            switch result {
            case .success(let data):
                let renderTime = Date()
                #if DEBUG
                print("✅ [Chat] 새로운 데이터 렌더링 - 시간: \(renderTime)")
                print("⏱️ [Chat] 새로운 데이터 렌더링 소요시간: \(renderTime.timeIntervalSince(responseTime))초")
                #endif
                completion(.success(data))
            case .failure(let error):
                #if DEBUG
                print("❌ [Chat] API 요청 실패 - 에러: \(error)")
                #endif
                completion(.failure(error))
            case .pathErr:
                #if DEBUG
                print("❌ [Chat] API 요청 실패 - pathErr")
                #endif
                completion(.pathErr)
            case .serverErr:
                #if DEBUG
                print("❌ [Chat] API 요청 실패 - serverErr")
                #endif
                completion(.serverErr)
            case .networkErr:
                #if DEBUG
                print("❌ [Chat] API 요청 실패 - networkErr")
                #endif
                completion(.networkErr)
            case .requestErr(let data):
                #if DEBUG
                print("❌ [Chat] API 요청 실패 - requestErr: \(data)")
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
    
    func leaveChatRoom(roomId: Int, completion: @escaping (NetworkResult<ChatLeaveResponseDTO>) -> Void) {
        #if DEBUG
        print("🔄 [Chat] 채팅방 나가기 요청 시작 - roomId: \(roomId)")
        #endif
        
        fetchData(target: .leaveChatRoom(roomId), responseData: ChatLeaveResponseDTO.self) { result in
            switch result {
            case .success(let data):
                #if DEBUG
                print("✅ [Chat] 채팅방 나가기 성공: \(data.message)")
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
