//
//  EditTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum EditTarget {
    case checkMyPort
    case editMyPort(_ bodyDTO: EditRequestBodyDTO)
}

extension EditTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .checkMyPort:
            return .authorization
        case .editMyPort(_):
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .checkMyPort:
            return .hasToken
        case .editMyPort(_):
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkMyPort:
            return .get
        case .editMyPort(_):
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .checkMyPort:
            return "/v1/users/me"
        case .editMyPort(_):
            return "/v1/users/me"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .checkMyPort:
            return .requestPlain
        case .editMyPort(let bodyDTO):
            return .requestWithMultipart(bodyDTO.toMultipartFormData())
        }
    }
}

extension EditRequestBodyDTO {
    func toMultipartFormData() -> (MultipartFormData) -> Void {
        return { formData in
            formData.append(self.username.data(using: .utf8) ?? Data(), withName: "username")
            formData.append(self.email.data(using: .utf8) ?? Data(), withName: "email")
            formData.append(self.description.data(using: .utf8) ?? Data(), withName: "description")
            formData.append(self.instagramId.data(using: .utf8) ?? Data(), withName: "instagramId")
            formData.append(self.password.data(using: .utf8) ?? Data(), withName: "password")
            
            if let webUrl = self.webUrl {
                formData.append(webUrl.data(using: .utf8) ?? Data(), withName: "webUrl")
            }
            
            if let portfolioImageUrl = self.portfolioImageUrl, !portfolioImageUrl.isEmpty {
                
                var keys: [Int] = [] // keys 배열 생성
                
                for (index, image) in portfolioImageUrl.enumerated() {
                    keys.append(index+1)
                    formData.append(image, withName: "portfolioImages", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                }
                
                // keys[] 배열을 폼 데이터에 추가
                for (index, key) in keys.enumerated() {
                    formData.append("\(key)".data(using: .utf8) ?? Data(), withName: "keys")
                }
            } else {
                print("portfolioImageUrl is nil or empty")
            }
            
            for (index, purpose) in self.userPurposes.enumerated() {
                formData.append("\(purpose)".data(using: .utf8) ?? Data(), withName: "userPurposes")
            }
            
            for (index, talent) in self.userTalents.enumerated() {
                formData.append(talent.data(using: .utf8) ?? Data(), withName: "userTalents")
            }
        }
    }
}
