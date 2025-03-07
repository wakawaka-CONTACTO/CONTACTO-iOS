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
    case editMyPort(_ bodyDTO: EditRequestDTO)
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

extension EditRequestDTO {
    func toMultipartFormData() -> (MultipartFormData) -> Void {
        return { formData in
            // EditRequestDTO에 맞게 데이터를 첨부하는 로직 구현
            formData.append(self.username.data(using: .utf8) ?? Data(), withName: "username")
            formData.append(self.email.data(using: .utf8) ?? Data(), withName: "email")
            formData.append(self.description.data(using: .utf8) ?? Data(), withName: "description")
            formData.append(self.instagramId.data(using: .utf8) ?? Data(), withName: "instagramId")
            formData.append(self.password.data(using: .utf8) ?? Data(), withName: "password")
            
            if let webUrl = self.webUrl {
                formData.append(webUrl.data(using: .utf8) ?? Data(), withName: "webUrl")
            }
            
            // 예시: 새 이미지 처리
            if let newImages = self.newPortfolioImages, !newImages.isEmpty {
                for (index, imageData) in newImages.enumerated() {
                    formData.append(imageData,
                                    withName: "newPortfolioImages",
                                    fileName: "newImage\(index).jpg",
                                    mimeType: "image/jpeg")
                }
            }
            
            // 예시: 기존 이미지 URL 처리
            if let existingUrls = self.existingPortfolioImageUrls, !existingUrls.isEmpty {
                for url in existingUrls {
                    formData.append(url.data(using: .utf8) ?? Data(),
                                    withName: "existingPortfolioImageUrls")
                }
            }
            
            // userPurposes 배열을 JSON 문자열로 변환하여 추가
            if let purposesData = try? JSONSerialization.data(withJSONObject: self.userPurposes, options: []),
               let purposesString = String(data: purposesData, encoding: .utf8) {
                formData.append(purposesString.data(using: .utf8) ?? Data(),
                                withName: "userPurposes",
                                mimeType: "application/json")
            }
            
            for (index, talent) in self.userTalents.enumerated() {
                formData.append(talent.data(using: .utf8) ?? Data(), withName: "userTalents")
            }

        }
    }
}
