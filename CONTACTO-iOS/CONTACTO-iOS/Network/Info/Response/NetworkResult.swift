//
//  NetworkResult.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

enum NetworkResult<T> {
    case success(T)     // 서버 통신 성공
    case requestErr(T)  // 요청에러 발생
    case pathErr // 경로 에러
    case serverErr  // 서버 내부 에러
    case networkErr // 네트워크 연결 실패
    case failure(NetworkError) // 실패
}

struct NetworkError: Error{
    let data: Data?
    let statusCode: Int?
    let underlyingError: Error?
}
