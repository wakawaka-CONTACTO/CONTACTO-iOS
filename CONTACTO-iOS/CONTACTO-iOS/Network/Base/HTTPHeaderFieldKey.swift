//
//  HTTPHeaderFieldKey.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

enum HTTPHeaderFieldKey: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case accessToken = "accessToken"
    case refreshtoken = "refreshtoken"
}

enum HTTPHeaderFieldValue: String {
    case json = "Application/json"
    case multipart = "multipart/form-data"
    case accessToken
}

enum HTTPHeaderType {
    case plain
    case hasToken
    case refreshToken
}

@frozen
enum Authorization {
    case authorization
    case unauthorization
    case reAuthorization
}
