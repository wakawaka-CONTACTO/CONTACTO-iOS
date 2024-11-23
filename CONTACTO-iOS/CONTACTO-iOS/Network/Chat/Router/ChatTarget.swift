//
//  ChatTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum ChatTarget {
    case chatRoomList
    
}

extension ChatTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .chatRoomList:
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .chatRoomList:
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .chatRoomList:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .chatRoomList:
            return "/v1/users/me/chatroom"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .chatRoomList:
            return .requestPlain
        }
    }
}
