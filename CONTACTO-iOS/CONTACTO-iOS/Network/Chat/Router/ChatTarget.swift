//
//  ChatTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum ChatTarget {
    case chatRoomList(_ page: Int, _ size: Int)
    case chatRoomMessage(_ roomId: Int)
    case chatMessage(_ roomId: Int, _ page: Int, _ size: Int)
    
}

extension ChatTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .chatRoomList(_, _):
            return .authorization
        case .chatRoomMessage(_):
            return .authorization
        case .chatMessage(_, _, _):
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .chatRoomList(_, _):
            return .hasToken
        case .chatRoomMessage(_):
            return .hasToken
        case .chatMessage(_, _, _):
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .chatRoomList(_, _):
            return .get
        case .chatRoomMessage(_):
            return .get
        case .chatMessage(_, _, _):
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .chatRoomList(_, _):
            return "/v1/users/me/chatroom"
        case .chatRoomMessage(let roomId):
            return "/v1/users/me/chatroom/\(roomId)"
        case .chatMessage(let roomId, _, _):
            return "/v1/users/me/chatroom/\(roomId)/messages"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .chatRoomList(let page, let size):
            return .requestQuery(["page": page, "size": size])
        case.chatRoomMessage(_):
            return .requestPlain
        case .chatMessage(_, let page, let size):
            let query = PageableRequest(page: page, size: size, sort: "createdAt,desc")
            return .requestQuery(query)
        }
    }
}
