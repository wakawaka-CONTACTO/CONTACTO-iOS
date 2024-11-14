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
    case detailPort(_ queryDTO: DetailRequestQueryDTO)
    case likeOrDislike(_ bodyDTO: LikeRequestBodyDTO)
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
        }
    }
    
    var path: String {
        switch self {
        case .homeList:
            return "/v1/users/portfolios"
        case .detailPort(_):
            return "/v1/users/portfolios"
        case .likeOrDislike(_):
            return "/v1/users/likes"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .homeList:
            return .requestPlain
        case .detailPort(let queryDTO):
            return .requestQuery(queryDTO)
        case .likeOrDislike(let bodyDTO):
            return .requestWithBody(bodyDTO)
        }
    }
}
