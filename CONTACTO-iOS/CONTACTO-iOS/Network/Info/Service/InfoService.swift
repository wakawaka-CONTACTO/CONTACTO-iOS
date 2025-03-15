//
//  InfoService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol InfoServiceProtocol {
    func deleteMe(completion: @escaping (NetworkResult<String?>) -> Void)

}

final class InfoService: APIRequestLoader<InfoTarget>, InfoServiceProtocol {
    func deleteMe(completion: @escaping (NetworkResult<String?>) -> Void) {
        fetchData(target: .deleteMe, responseData: String?.self, completion: completion)
    }
}
