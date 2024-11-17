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
            
            if let portfolioImages = self.portfolioImages, !portfolioImages.isEmpty {
                print("portfolioImages is not empty. Count: \(portfolioImages.count)")
                for (index, image) in portfolioImages.enumerated() {
                    print("Index: \(index), Photo Size: \(image.count) bytes")
                    formData.append(image, withName: "portfolioImages", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                }
            } else {
                print("portfolioImages is nil or empty")
            }
            
            for (index, purpose) in self.userPurposes.enumerated() {
                formData.append("\(purpose)".data(using: .utf8) ?? Data(), withName: "userPurposes[\(index)]")
            }
            
            for (index, talent) in self.userTalents.enumerated() {
                formData.append(talent.data(using: .utf8) ?? Data(), withName: "userTalents[\(index)]")
            }
        }
    }
}
