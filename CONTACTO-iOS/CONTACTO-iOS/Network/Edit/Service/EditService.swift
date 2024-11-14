//
//  EditService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol EditServiceProtocol {
    func checkMyPort(completion: @escaping (NetworkResult<BaseResponse<MyDetailResponseDTO>>) -> Void)
    
    func editMyPort(bodyDTO: EditRequestBodyDTO, completion: @escaping (NetworkResult<BaseResponse<MyDetailResponseDTO>>) -> Void)

}

final class EditService: APIRequestLoader<EditTarget>, EditServiceProtocol {
    func checkMyPort(completion: @escaping (NetworkResult<BaseResponse<MyDetailResponseDTO>>) -> Void) {
        fetchData(target: .checkMyPort, responseData: BaseResponse<MyDetailResponseDTO>.self, completion: completion)
    }
    
    func editMyPort(bodyDTO: EditRequestBodyDTO, completion: @escaping (NetworkResult<BaseResponse<MyDetailResponseDTO>>) -> Void) {
        fetchData(target: .editMyPort(bodyDTO), responseData: BaseResponse<MyDetailResponseDTO>.self, completion: completion)
    }
    
}
