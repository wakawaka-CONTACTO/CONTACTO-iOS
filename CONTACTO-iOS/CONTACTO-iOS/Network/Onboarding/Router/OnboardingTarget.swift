//
//  OnboardingTarget.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import Alamofire

enum OnboardingTarget {
    case signup(_ bodyDTO: SignUpRequestBodyDTO)
    case login(_ bodyDTO: LoginRequestBodyDTO)
    case emailCheck(_ bodyDTO: EmailCheckRequestBodyDTO)
    case emailSend(_ bodyDTO: EmailSendRequestBodyDTO)
    case signHelp(_ bodyDTO: SignInHelpRequestBodyDTO)
    case reissue
    
}

extension OnboardingTarget: TargetType {
    var authorization: Authorization {
        switch self {
        case .signup(_):
            return .unauthorization
        case .login(_):
            return .unauthorization
        case .emailCheck(_):
            return .unauthorization
        case .emailSend(_):
            return .unauthorization
        case .signHelp(_):
            return .unauthorization
        case .reissue:
            return .authorization
        }
    }
    
    var headerType: HTTPHeaderType {
        switch self {
        case .signup(_):
            return .plain
        case .login(_):
            return .plain
        case .emailCheck(_):
            return .plain
        case .emailSend(_):
            return .plain
        case .signHelp(_):
            return .plain
        case .reissue:
            return .hasToken
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signup(_):
            return .post
        case .login(_):
            return .post
        case .emailCheck(_):
            return .post
        case .emailSend(_):
            return .post
        case .signHelp(_):
            return .post
        case .reissue:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .signup(_):
            return "/v1/users/signup"
        case .login(_):
            return "/v1/users/signin"
        case .emailCheck(_):
            return "/v1/auth/emailcheck"
        case .emailSend(_):
            return "/v1/auth/emailsend"
        case .signHelp(_):
            return "/v1/users/signin/help"
        case .reissue:
            return "/v1/auth/reissue"
        }
    }
    
    var parameters: RequestParams {
        switch self {
        case .signup(let bodyDTO):
            return .requestWithMultipart(bodyDTO.toMultipartFormData())
        case .login(let bodyDTO):
            return .requestWithBody(bodyDTO)
        case .emailCheck(let bodyDTO):
            return .requestWithBody(bodyDTO)
        case .emailSend(let bodyDTO):
            return .requestWithBody(bodyDTO)
        case .signHelp(let bodyDTO):
            return .requestWithBody(bodyDTO)
        case .reissue:
            return .requestPlain
        }
    }
}

extension SignUpRequestBodyDTO {
    func toMultipartFormData() -> (MultipartFormData) -> Void {
        return { formData in
            formData.append(self.name.data(using: .utf8) ?? Data(), withName: "name")
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
