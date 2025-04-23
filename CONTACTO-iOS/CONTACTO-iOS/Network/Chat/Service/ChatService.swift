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
    private let chatRoomListCacheKey = "chatRoomList"
    
    func chatRoomList(page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[ChatListResponseDTO]>>) -> Void) {
        let startTime = Date()
        print("🔄 [Chat] 채팅방 리스트 조회 시작 - 시간: \(startTime)")
        
        // 캐시된 데이터가 있는지 확인
        if let cachedData = getCachedChatRoomList() {
            let cacheRenderTime = Date()
            print("✅ [Chat] 캐시된 데이터 렌더링 - 시간: \(cacheRenderTime)")
            print("⏱️ [Chat] 캐시 데이터 렌더링 소요시간: \(cacheRenderTime.timeIntervalSince(startTime))초")
            completion(.success(cachedData))
        }
        
        // API 요청
        fetchData(target: .chatRoomList(page, size), responseData: PageableResponse<[ChatListResponseDTO]>.self) { [weak self] result in
            let responseTime = Date()
            print("📥 [Chat] API 응답 수신 - 시간: \(responseTime)")
            print("⏱️ [Chat] API 응답 소요시간: \(responseTime.timeIntervalSince(startTime))초")
            
            switch result {
            case .success(let data):
                // 성공 시 캐시 업데이트
                self?.cacheChatRoomList(data)
                let renderTime = Date()
                print("✅ [Chat] 새로운 데이터 렌더링 - 시간: \(renderTime)")
                print("⏱️ [Chat] 새로운 데이터 렌더링 소요시간: \(renderTime.timeIntervalSince(responseTime))초")
                completion(.success(data))
            case .failure(let error):
                print("❌ [Chat] API 요청 실패 - 에러: \(error)")
                completion(.failure(error))
            case .pathErr:
                print("❌ [Chat] API 요청 실패 - pathErr")
                completion(.pathErr)
            case .serverErr:
                print("❌ [Chat] API 요청 실패 - serverErr")
                completion(.serverErr)
            case .networkErr:
                print("❌ [Chat] API 요청 실패 - networkErr")
                completion(.networkErr)
            case .requestErr(let data):
                print("❌ [Chat] API 요청 실패 - requestErr: \(data)")
                completion(.requestErr(data))
            }
        }
    }
    
    private func getCachedChatRoomList() -> PageableResponse<[ChatListResponseDTO]>? {
        let startTime = Date()
        print("🔍 [Chat] 캐시 데이터 조회 시작 - 시간: \(startTime)")
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            print("❌ [Chat] URL 생성 실패")
            return nil
        }
        
        let request = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(PageableResponse<[ChatListResponseDTO]>.self, from: cachedResponse.data)
                let endTime = Date()
                print("✅ [Chat] 캐시 데이터 조회 성공 - 시간: \(endTime)")
                print("⏱️ [Chat] 캐시 데이터 조회 소요시간: \(endTime.timeIntervalSince(startTime))초")
                return data
            } catch {
                print("❌ [Chat] 캐시된 채팅방 리스트 디코딩 실패: \(error)")
                return nil
            }
        }
        print("ℹ️ [Chat] 캐시된 데이터 없음")
        return nil
    }
    
    private func cacheChatRoomList(_ data: PageableResponse<[ChatListResponseDTO]>) {
        let startTime = Date()
        print("💾 [Chat] 캐시 저장 시작 - 시간: \(startTime)")
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            print("❌ [Chat] URL 생성 실패")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                print("❌ [Chat] HTTPURLResponse 생성 실패")
                return
            }
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            let endTime = Date()
            print("✅ [Chat] 캐시 저장 완료 - 시간: \(endTime)")
            print("⏱️ [Chat] 캐시 저장 소요시간: \(endTime.timeIntervalSince(startTime))초")
        } catch {
            print("❌ [Chat] 채팅방 리스트 캐싱 실패: \(error)")
        }
    }
    
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void) {
        fetchData(target: .chatRoomMessage(roomId), responseData: ChatRoomResponseDTO.self, completion: completion)
    }
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void) {
        fetchData(target: .chatMessage(roomId, page, size), responseData: PageableResponse<[Message]>.self, completion: completion)
    }
}
