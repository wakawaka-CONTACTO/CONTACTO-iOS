//
//  HomeService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol HomeServiceProtocol {
    
    func homeList(completion: @escaping (NetworkResult<BaseResponse<[PortfoliosResponseDTO]>>) -> Void)
    
    func detailPort(queryDTO: DetailRequestQueryDTO, completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void)
    
    func likeOrDislike(bodyDTO: LikeRequestBodyDTO, completion: @escaping (NetworkResult<BaseResponse<LikeResponseDTO>>) -> Void)
}

final class HomeService: APIRequestLoader<HomeTarget>, HomeServiceProtocol {
    func homeList(completion: @escaping (NetworkResult<BaseResponse<[PortfoliosResponseDTO]>>) -> Void) {
        fetchData(target: .homeList, responseData: BaseResponse<[PortfoliosResponseDTO]>.self, completion: completion)
    }
    
    func detailPort(queryDTO: DetailRequestQueryDTO, completion: @escaping (NetworkResult<MyDetailResponseDTO>) -> Void) {
        fetchData(target: .detailPort(queryDTO), responseData: MyDetailResponseDTO.self, completion: completion)
    }
    
    func likeOrDislike(bodyDTO: LikeRequestBodyDTO, completion: @escaping (NetworkResult<BaseResponse<LikeResponseDTO>>) -> Void) {
        fetchData(target: .likeOrDislike(bodyDTO), responseData: BaseResponse<LikeResponseDTO>.self, completion: completion)
    }
}
