//
//  OnboardingService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol OnboardingServiceProtocol {
//    func myList(queryDTO: MyPINGLEListRequestQueryDTO, completion: @escaping (NetworkResult<BaseResponse<[MyPINGLEResponseDTO]>>) -> Void)
}

final class OnboardingService: APIRequestLoader<MyPINGLETarget>, OnboardingServiceProtocol {
    func myList(queryDTO: MyPINGLEListRequestQueryDTO, completion: @escaping (NetworkResult<BaseResponse<[MyPINGLEResponseDTO]>>) -> Void) {
        fetchData(target: .myList(queryDTO: queryDTO),
                  responseData: BaseResponse<[MyPINGLEResponseDTO]>.self, completion: completion)
    }
}
