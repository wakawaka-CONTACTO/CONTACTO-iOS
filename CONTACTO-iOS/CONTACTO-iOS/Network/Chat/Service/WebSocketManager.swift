//
//  WebSocketManager.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 2024-06-29.
//

import Foundation
import StompClientLib

protocol WebSocketManagerDelegate: AnyObject {
    func didReceiveMessage(_ message: Message, forRoomId: Int)
    func didChangeConnectionStatus(isConnected: Bool)
}

class WebSocketManager: NSObject {
    // 싱글톤 인스턴스
    static let shared = WebSocketManager()
    
    // STOMP 클라이언트
    private var socketClient = StompClientLib()
    private(set) var isConnected = false
    
    // 연결 시도 관련 변수
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectInterval: TimeInterval = 3.0
    
    // 활성 채팅방 관리
    private var activeRoomId: Int?
    private var subscribedRooms = Set<Int>()
    
    // 델리게이트 등록을 위한 약한 참조 배열
    private var delegates = [Int: NSHashTable<AnyObject>]()
    
    private override init() {
        super.init()
    }
    
    // 델리게이트 추가
    func addDelegate(_ delegate: WebSocketManagerDelegate, forRoomId roomId: Int) {
        let roomDelegates = delegates[roomId] ?? NSHashTable<AnyObject>.weakObjects()
        roomDelegates.add(delegate)
        delegates[roomId] = roomDelegates
        
        #if DEBUG
        print("WebSocketManager: 방 ID \(roomId)에 대한 델리게이트 등록")
        #endif
    }
    
    // 델리게이트 제거
    func removeDelegate(_ delegate: WebSocketManagerDelegate, forRoomId roomId: Int) {
        guard let roomDelegates = delegates[roomId] else { return }
        roomDelegates.remove(delegate)
        
        #if DEBUG
        print("WebSocketManager: 방 ID \(roomId)에 대한 델리게이트 제거")
        #endif
        
        // 델리게이트가 없으면 해당 방의 엔트리 제거
        if roomDelegates.count == 0 {
            delegates.removeValue(forKey: roomId)
        }
    }
    
    // 웹소켓 연결
    func connect() {
        #if DEBUG
        print("WebSocketManager: 웹소켓 연결 시도")
        #endif
        
        // 이미 연결된 경우 리턴
        guard !isConnected else {
            #if DEBUG
            print("WebSocketManager: 이미 연결됨")
            #endif
            return
        }
        
        guard let url = URL(string: "\(Config.chatBaseURL)?userId=\(KeychainHandler.shared.userID)&accessToken=\(KeychainHandler.shared.accessToken)&serverKey=contacto-chat-service") else {
            #if DEBUG
            print("WebSocketManager: 유효하지 않은 URL")
            #endif
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.setValue(KeychainHandler.shared.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("contacto-chat-service", forHTTPHeaderField: "server-key")
        
        socketClient.openSocketWithURLRequest(
            request: NSURLRequest(url: url),
            delegate: self
        )
    }
    
    // 웹소켓 연결 끊기
    func disconnect() {
        #if DEBUG
        print("WebSocketManager: 웹소켓 연결 끊기")
        #endif
        
        if isConnected {
            // 구독 중인 모든 방 구독 해제
            for roomId in subscribedRooms {
                unsubscribeFromRoom(roomId)
            }
            
            // 연결 끊기
            socketClient.disconnect()
        }
        
        // 재연결 타이머 중지
        stopReconnectTimer()
        reconnectAttempts = 0
    }
    
    // 특정 채팅방 구독
    func subscribeToRoom(_ roomId: Int) {
        guard isConnected else {
            #if DEBUG
            print("WebSocketManager: 연결되지 않아 방 \(roomId)을 구독할 수 없습니다.")
            #endif
            return
        }
        
        // 이미 구독 중인 방인지 확인
        guard !subscribedRooms.contains(roomId) else {
            #if DEBUG
            print("WebSocketManager: 방 \(roomId)는 이미 구독 중입니다.")
            #endif
            return
        }
        
        var headers = ["Authorization": KeychainHandler.shared.accessToken]
        headers["id"] = "sub-\(roomId)"
        headers["server-key"] = "contacto-chat-service"
        
        #if DEBUG
        print("WebSocketManager: 방 \(roomId) 구독")
        #endif
        
        socketClient.subscribeWithHeader(destination: "/topic/\(roomId)", withHeader: headers)
        subscribedRooms.insert(roomId)
        activeRoomId = roomId
        
        // 서버에 활성화 상태 알림
        activateRoomOnServer(roomId: roomId)
    }
    
    // 특정 채팅방 구독 해제
    func unsubscribeFromRoom(_ roomId: Int) {
        #if DEBUG
        print("WebSocketManager: 방 \(roomId) 구독 해제")
        #endif
        
        socketClient.unsubscribe(destination: "/topic/\(roomId)")
        subscribedRooms.remove(roomId)
        
        // 활성화된 방이었다면 활성화 해제
        if activeRoomId == roomId {
            activeRoomId = nil
        }
    }
    
    // 활성 채팅방 설정
    func setActiveRoom(_ roomId: Int?) {
        let previousActiveRoomId = activeRoomId
        activeRoomId = roomId
        
        #if DEBUG
        if let roomId = roomId {
            print("WebSocketManager: 활성화된 채팅방 ID 설정 - \(roomId)")
        } else {
            print("WebSocketManager: 활성화된 채팅방 없음")
        }
        #endif
        
        // 새로운 활성 채팅방이 있고 아직 구독하지 않았다면 구독
        if let roomId = roomId, !subscribedRooms.contains(roomId) && isConnected {
            subscribeToRoom(roomId)
        }
    }
    
    // 서버에 방 활성화 상태 알림
    private func activateRoomOnServer(roomId: Int) {
        // 서버 API 호출하여 현재 활성화된 채팅방 설정
        NetworkService.shared.chatService.chatRoomMessage(roomId: roomId) { result in
            switch result {
            case .success:
                #if DEBUG
                print("WebSocketManager: 방 ID \(roomId) 활성화 상태 서버 동기화 성공")
                #endif
            default:
                #if DEBUG
                print("WebSocketManager: 방 ID \(roomId) 활성화 상태 서버 동기화 실패")
                #endif
            }
        }
    }
    
    // 메시지 전송
    func sendMessage(_ message: Message, to roomId: Int) {
        guard isConnected else {
            #if DEBUG
            print("WebSocketManager: 연결되지 않아 메시지를 보낼 수 없습니다.")
            #endif
            return
        }
        
        if let messageData = try? JSONEncoder().encode(message) {
            var headers = ["Authorization": KeychainHandler.shared.accessToken]
            headers["content-type"] = "application/json"
            headers["server-key"] = "contacto-chat-service"
            
            socketClient.sendMessage(
                message: String(data: messageData, encoding: .utf8) ?? "",
                toDestination: "/app/chat.send/\(roomId)",
                withHeaders: headers,
                withReceipt: nil
            )
            
            #if DEBUG
            print("WebSocketManager: 메시지 전송 - 방 ID: \(roomId)")
            #endif
        }
    }
    
    // 재연결 타이머 설정
    private func startReconnectTimer() {
        stopReconnectTimer()
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.reconnectAttempts < self.maxReconnectAttempts {
                self.reconnectAttempts += 1
                
                #if DEBUG
                print("WebSocketManager: 재연결 시도 \(self.reconnectAttempts)/\(self.maxReconnectAttempts)")
                #endif
                
                self.connect()
            } else {
                #if DEBUG
                print("WebSocketManager: 최대 재연결 시도 횟수 초과")
                #endif
                
                self.stopReconnectTimer()
            }
        }
    }
    
    // 재연결 타이머 중지
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    // 연결 상태 변경 알림
    private func notifyConnectionStatusChange() {
        for (roomId, roomDelegates) in delegates {
            for delegate in roomDelegates.allObjects {
                if let delegate = delegate as? WebSocketManagerDelegate {
                    delegate.didChangeConnectionStatus(isConnected: isConnected)
                }
            }
        }
    }
}

// MARK: - StompClientLibDelegate
extension WebSocketManager: StompClientLibDelegate {
    func stompClientDidConnect(client: StompClientLib) {
        #if DEBUG
        print("WebSocketManager: STOMP 연결 성공")
        #endif
        
        isConnected = true
        reconnectAttempts = 0
        stopReconnectTimer()
        
        // 연결 상태 변경 알림
        notifyConnectionStatusChange()
        
        // 활성화된 채팅방이 있으면 구독
        if let activeRoomId = activeRoomId {
            subscribeToRoom(activeRoomId)
        }
        
        // 이전에 구독했던 모든 방 다시 구독
        for roomId in subscribedRooms {
            if roomId != activeRoomId { // 활성화된 방은 이미 위에서 구독했음
                subscribeToRoom(roomId)
            }
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib) {
        #if DEBUG
        print("WebSocketManager: STOMP 연결 종료")
        #endif
        
        isConnected = false
        subscribedRooms.removeAll()
        
        // 연결 상태 변경 알림
        notifyConnectionStatusChange()
        
        // 자동 재연결 시도
        startReconnectTimer()
    }
    
    func stompClient(client: StompClientLib,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?,
                     withHeader header: [String : String]?,
                     withDestination destination: String) {
        #if DEBUG
        print("WebSocketManager: 메시지 수신 - 목적지: \(destination)")
        #endif
        
        guard let messageString = stringBody,
              let data = messageString.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: data) else {
            #if DEBUG
            print("WebSocketManager: 유효하지 않은 메시지 형식")
            #endif
            return
        }
        
        // 현재 사용자가 보낸 메시지는 건너뜀 (에코 방지)
        if message.senderId == Int(KeychainHandler.shared.userID) {
            #if DEBUG
            print("WebSocketManager: 사용자 본인이 보낸 메시지 처리 건너뜀")
            #endif
            return
        }
        
        // 메시지의 채팅방 ID 추출 (/topic/{roomId} 형식)
        guard let roomId = extractRoomIdFromDestination(destination) else {
            #if DEBUG
            print("WebSocketManager: 목적지에서 채팅방 ID를 추출할 수 없음")
            #endif
            return
        }
        
        // 해당 방에 등록된 모든 델리게이트에 메시지 전달
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let roomDelegates = self.delegates[roomId] {
                for delegate in roomDelegates.allObjects {
                    if let delegate = delegate as? WebSocketManagerDelegate {
                        delegate.didReceiveMessage(message, forRoomId: roomId)
                    }
                }
            }
        }
    }
    
    // 목적지 경로에서 채팅방 ID 추출 (/topic/{roomId})
    private func extractRoomIdFromDestination(_ destination: String) -> Int? {
        let components = destination.split(separator: "/")
        guard components.count >= 2 else { return nil }
        return Int(components[components.count - 1])
    }
    
    func serverDidSendReceipt(client: StompClientLib, withReceiptId receiptId: String) {
        #if DEBUG
        print("WebSocketManager: 수신 확인 - ID: \(receiptId)")
        #endif
    }
    
    func serverDidSendError(client: StompClientLib, withErrorMessage description: String, detailedErrorMessage message: String?) {
        #if DEBUG
        print("WebSocketManager: 오류 발생 - \(description), 상세: \(message ?? "없음")")
        #endif
    }
    
    func serverDidSendPing() {
        #if DEBUG
        print("WebSocketManager: 서버 핑 수신")
        #endif
    }
} 