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
}

extension InfoTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .deleteMe:
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .deleteMe:
            return .hasToken
            
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .deleteMe:
            return .delete
            
        }
    }
    
    var path: String {
        switch self {
        case .deleteMe:
            return "/api/v1/users/me"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .deleteMe:
            return .requestPlain
        }
    }
}
