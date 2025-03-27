//
//  HomeTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum HomeTarget {
    case homeList
    case detailPort(_ userId: Int)
    case likeOrDislike(_ bodyDTO: LikeRequestBodyDTO)
    case blockUser(_ blockedUserId: Int)
    case reportUser(_ bodyDTO: ReportRequestBodyDTO)
}

extension HomeTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .homeList:
            return .authorization
        case .detailPort(_):
            return .authorization
        case .likeOrDislike(_):
            return .authorization
        case .blockUser(_):
            return .authorization
        case .reportUser(_):
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .homeList:
            return .hasToken
        case .detailPort(_):
            return .hasToken
        case .likeOrDislike(_):
            return .hasToken
        case .blockUser(_):
            return .hasToken
        case .reportUser(_):
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .homeList:
            return .get
        case .detailPort(_):
            return .get
        case .likeOrDislike(_):
            return .post
        case .blockUser(_):
            return .post
        case .reportUser(_):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .homeList:
            return "/v1/users/portfolios"
        case .detailPort(let userId):
            return "/v1/users/portfolios/\(userId)"
        case .likeOrDislike(_):
            return "/v1/users/likes"
        case .blockUser(let blockedUserId):
            return "/v1/users/blocks/\(blockedUserId)"
        case .reportUser(_):
            return "/v1/users/reports"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .homeList:
            return .requestQuery(["page": 0, "size": 10])
        case .detailPort(_):
            return .requestPlain
        case .likeOrDislike(let bodyDTO):
            return .requestWithBody(bodyDTO)
        case .blockUser(_):
            return .requestPlain
        case .reportUser(let bodyDTO):
            return .requestWithBody(bodyDTO)
        }
    }
}
