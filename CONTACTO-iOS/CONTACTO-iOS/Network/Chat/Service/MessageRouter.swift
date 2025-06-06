//
//  MessageRouter.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 2024-06-29.
//

import Foundation

protocol MessageRouterDelegate: AnyObject {
    func didReceiveMessage(_ message: Message, inRoomId: Int)
    func didUpdateUnreadCount(forRoomId: Int, count: Int)
}

class MessageRouter {
    // 싱글톤 인스턴스
    static let shared = MessageRouter()
    
    // 채팅방별 읽지 않은 메시지 카운트
    private var unreadMessageCounts: [Int: Int] = [:]
    
    // 현재 활성 채팅방 ID
    private var activeChatRoomId: Int?
    
    // 델리게이트 관리
    private var delegates = [Int: NSHashTable<AnyObject>]()
    
    // 초기화
    private init() {
        // WebSocketManager의 델리게이트로 등록
        setupWebSocketDelegate()
    }
    
    // WebSocketManager 델리게이트 설정
    private func setupWebSocketDelegate() {
        // 해당 메서드는 글로벌 구독 방식을 사용할 때 필요
    }
    
    // 읽지 않은 메시지 수 가져오기
    func getUnreadCount(forRoomId roomId: Int) -> Int {
        return unreadMessageCounts[roomId] ?? 0
    }
    
    // 읽지 않은 메시지 수 설정
    func setUnreadCount(forRoomId roomId: Int, count: Int) {
        unreadMessageCounts[roomId] = count
        notifyUnreadCountChanged(forRoomId: roomId, count: count)
    }
    
    // 읽지 않은 메시지 수 증가
    func incrementUnreadCount(forRoomId roomId: Int) {
        let currentCount = unreadMessageCounts[roomId] ?? 0
        let newCount = currentCount + 1
        unreadMessageCounts[roomId] = newCount
        notifyUnreadCountChanged(forRoomId: roomId, count: newCount)
    }
    
    // 읽지 않은 메시지 수 초기화
    func resetUnreadCount(forRoomId roomId: Int) {
        unreadMessageCounts[roomId] = 0
        notifyUnreadCountChanged(forRoomId: roomId, count: 0)
    }
    
    // 활성 채팅방 설정
    func setActiveChatRoom(_ roomId: Int?) {
        activeChatRoomId = roomId
        
        // 활성 채팅방의 읽지 않은 메시지 수 리셋
        if let roomId = roomId {
            resetUnreadCount(forRoomId: roomId)
        }
    }
    
    // 특정 채팅방의 델리게이트 등록
    func addDelegate(_ delegate: MessageRouterDelegate, forRoomId roomId: Int) {
        let roomDelegates = delegates[roomId] ?? NSHashTable<AnyObject>.weakObjects()
        roomDelegates.add(delegate)
        delegates[roomId] = roomDelegates
    }
    
    // 특정 채팅방의 델리게이트 제거
    func removeDelegate(_ delegate: MessageRouterDelegate, forRoomId roomId: Int) {
        guard let roomDelegates = delegates[roomId] else { return }
        roomDelegates.remove(delegate)
        
        // 델리게이트가 없으면 해당 방의 엔트리 제거
        if roomDelegates.count == 0 {
            delegates.removeValue(forKey: roomId)
        }
    }
    
    // 모든 델리게이트에 메시지 전달
    func routeMessage(_ message: Message, toRoomId roomId: Int) {
        // 활성 채팅방이 아니면 읽지 않은 메시지 수 증가
        if activeChatRoomId != roomId {
            incrementUnreadCount(forRoomId: roomId)
        }
        
        // 해당 방에 등록된 모든 델리게이트에 메시지 전달
        if let roomDelegates = delegates[roomId] {
            for delegate in roomDelegates.allObjects {
                if let delegate = delegate as? MessageRouterDelegate {
                    delegate.didReceiveMessage(message, inRoomId: roomId)
                }
            }
        }
    }
    
    // 읽지 않은 메시지 수 변경 알림
    private func notifyUnreadCountChanged(forRoomId roomId: Int, count: Int) {
        // 해당 방에 등록된 모든 델리게이트에 카운트 변경 전달
        if let roomDelegates = delegates[roomId] {
            for delegate in roomDelegates.allObjects {
                if let delegate = delegate as? MessageRouterDelegate {
                    delegate.didUpdateUnreadCount(forRoomId: roomId, count: count)
                }
            }
        }
    }
    
    // 모든 채팅방의 총 읽지 않은 메시지 수
    func getTotalUnreadCount() -> Int {
        var total = 0
        for (roomId, count) in unreadMessageCounts {
            // 현재 활성화된 채팅방은 제외
            if roomId != activeChatRoomId {
                total += count
            }
        }
        return total
    }
    
    // 채팅방 나갔을 때의 처리
    func handleLeaveChatRoom(_ roomId: Int) {
        // 읽지 않은 메시지 카운트에서 제거
        unreadMessageCounts.removeValue(forKey: roomId)
        
        // 델리게이트 등록 제거
        delegates.removeValue(forKey: roomId)
        
        // 활성 채팅방이었다면 리셋
        if activeChatRoomId == roomId {
            activeChatRoomId = nil
        }
    }
} 