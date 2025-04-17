//
//  InfoTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum InfoTarget {
    case deleteMe
    case logout(String)
}

extension InfoTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .deleteMe, .logout:
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .deleteMe, .logout:
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .deleteMe:
            return .delete
        case .logout:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .deleteMe:
            return "/v1/users/me"
        case .logout:
            return "/v1/users/logout"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .deleteMe:
            return .requestPlain
        case .logout(let deviceId):
            return .requestWithBody(["deviceId": deviceId])
        }
    }
}
