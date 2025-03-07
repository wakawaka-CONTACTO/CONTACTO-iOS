//
//  EditService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

    // TODO : error에 따른 reponse 바꾸기 필요
protocol EditServiceProtocol {
    func checkMyPort(completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void)
    
    func editMyPort(bodyDTO: EditRequestDTO, completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void)

}

final class EditService: APIRequestLoader<EditTarget>, EditServiceProtocol {
    func checkMyPort(completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void) {
        fetchData(target: .checkMyPort, responseData: MyDetailResponseDTO.self, completion: completion)
    }
    
    func editMyPort(bodyDTO: EditRequestDTO, completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void) {
        fetchData(target: .editMyPort(bodyDTO), responseData: MyDetailResponseDTO.self, completion: completion)
    }
}
