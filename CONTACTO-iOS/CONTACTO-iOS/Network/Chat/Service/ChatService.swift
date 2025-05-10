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
        #if DEBUG
        print("🔄 [Chat] 채팅방 리스트 조회 시작 - 시간: \(startTime)")
        #endif
        
        // page가 0일 때만 캐시 확인
        if page == 0 {
            if let cachedData = getCachedChatRoomList() {
                let cacheRenderTime = Date()
                #if DEBUG
                print("✅ [Chat] 캐시된 데이터 렌더링 - 시간: \(cacheRenderTime)")
                print("⏱️ [Chat] 캐시 데이터 렌더링 소요시간: \(cacheRenderTime.timeIntervalSince(startTime))초")
                #endif
                completion(.success(cachedData))
            }
        }
        
        // API 요청
        fetchData(target: .chatRoomList(page, size), responseData: PageableResponse<[ChatListResponseDTO]>.self) { [weak self] result in
            let responseTime = Date()
            #if DEBUG
            print("📥 [Chat] API 응답 수신 - 시간: \(responseTime)")
            print("⏱️ [Chat] API 응답 소요시간: \(responseTime.timeIntervalSince(startTime))초")
            #endif
            
            switch result {
            case .success(let data):
                // 첫 페이지 데이터만 캐시
                if page == 0 {
                    self?.cacheChatRoomList(data)
                }
                
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
    
    private func getCachedChatRoomList() -> PageableResponse<[ChatListResponseDTO]>? {
        let startTime = Date()
        #if DEBUG
        print("🔍 [Chat] 캐시 데이터 조회 시작 - 시간: \(startTime)")
        #endif
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            #if DEBUG
            print("❌ [Chat] URL 생성 실패")
            #endif
            return nil
        }
        
        let request = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(PageableResponse<[ChatListResponseDTO]>.self, from: cachedResponse.data)
                let endTime = Date()
                #if DEBUG
                print("✅ [Chat] 캐시 데이터 조회 성공 - 시간: \(endTime)")
                print("⏱️ [Chat] 캐시 데이터 조회 소요시간: \(endTime.timeIntervalSince(startTime))초")
                #endif
                return data
            } catch {
                #if DEBUG
                print("❌ [Chat] 캐시된 채팅방 리스트 디코딩 실패: \(error)")
                #endif
                return nil
            }
        }
        #if DEBUG
        print("ℹ️ [Chat] 캐시된 데이터 없음")
        #endif
        return nil
    }
    
    private func cacheChatRoomList(_ data: PageableResponse<[ChatListResponseDTO]>) {
        let startTime = Date()
        #if DEBUG
        print("💾 [Chat] 캐시 저장 시작 - 시간: \(startTime)")
        #endif
        
        guard let url = URL(string: "https://api.contacto.site/v1/users/me/chatroom") else {
            #if DEBUG
            print("❌ [Chat] URL 생성 실패")
            #endif
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                #if DEBUG
                print("❌ [Chat] HTTPURLResponse 생성 실패")
                #endif
                return
            }
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
            let endTime = Date()
            #if DEBUG
            print("✅ [Chat] 캐시 저장 완료 - 시간: \(endTime)")
            print("⏱️ [Chat] 캐시 저장 소요시간: \(endTime.timeIntervalSince(startTime))초")
            #endif
        } catch {
            #if DEBUG
            print("❌ [Chat] 채팅방 리스트 캐싱 실패: \(error)")
            #endif
        }
    }
    
    func chatRoomMessage(roomId: Int, completion: @escaping (NetworkResult<ChatRoomResponseDTO>) -> Void) {
        fetchData(target: .chatRoomMessage(roomId), responseData: ChatRoomResponseDTO.self, completion: completion)
    }
    
    func chatMessages(roomId: Int, page: Int, size: Int, completion: @escaping (NetworkResult<PageableResponse<[Message]>>) -> Void) {
        fetchData(target: .chatMessage(roomId, page, size), responseData: PageableResponse<[Message]>.self, completion: completion)
    }
}
