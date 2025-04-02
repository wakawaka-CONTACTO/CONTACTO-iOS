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
    case emailExist(_ queryDTO: EmailExistRequestQueryDTO)
    case updatePwd(_ bodyDTO: LoginRequestBodyDTO)
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
            return .reAuthorization
        case .emailExist(_):
            return .unauthorization
        case .updatePwd(_):
            return .unauthorization
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
            return .refreshToken
        case .emailExist(_):
            return .plain
        case .updatePwd(_):
            return .plain
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
        case .emailExist(_):
            return .get
        case .updatePwd(_):
            return .patch
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
        case .emailExist:
            return "/v1/users/me/email"
        case .updatePwd:
            return "/v1/users/me/pwd"
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
        case .emailExist(let queryDTO):
            return .requestQuery(queryDTO)
        case .updatePwd(let bodyDTO):
            return .requestWithBody(bodyDTO)
        }
    }
}

extension SignUpRequestBodyDTO {
    func toMultipartFormData() -> (MultipartFormData) -> Void {
        return { formData in
            if let userSignUpReqData = try? JSONEncoder().encode(self.userSignUpReq) {
                formData.append(userSignUpReqData, withName: "userSignUpReq", mimeType: "application/json")
            } else {
                print("Failed to encode userSignUpReq")
            }
            
            formData.append(self.userSignUpReq.name.data(using: .utf8) ?? Data(), withName: "name")
            formData.append(self.userSignUpReq.loginType.data(using: .utf8) ?? Data(), withName: "loginType")
            formData.append(self.userSignUpReq.email.data(using: .utf8) ?? Data(), withName: "email")
            formData.append(self.userSignUpReq.description.data(using: .utf8) ?? Data(), withName: "description")
            formData.append(self.userSignUpReq.instagramId.data(using: .utf8) ?? Data(), withName: "instagramId")
            formData.append(self.userSignUpReq.password.data(using: .utf8) ?? Data(), withName: "password")
            formData.append(self.userSignUpReq.nationality.data(using: .utf8) ?? Data(), withName: "nationality")
            if let webUrl = self.userSignUpReq.webUrl {
                formData.append(webUrl.data(using: .utf8) ?? Data(), withName: "webUrl")
            }
            
            if let portfolioImageUrl = self.images, !portfolioImageUrl.isEmpty {
                for (index, image) in portfolioImageUrl.enumerated() {
                    formData.append(image, withName: "portfolioImgs", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                }
            } else {
                print("portfolioImageUrl is nil or empty")
            }
            
            let purposeArray = self.purpose.map { purpose in
                return ["purposeType": purpose.purposeType]
            }
            
            if let purposeData = try? JSONSerialization.data(withJSONObject: purposeArray, options: []),
               let purposeString = String(data: purposeData, encoding: .utf8) {
                formData.append(purposeString.data(using: .utf8) ?? Data(),
                                withName: "purpose",
                                mimeType: "application/json")
            }
            
            let talentArray = self.talent.map { talent in
                return ["talentType": talent.talentType]
            }
            
            if let talentData = try? JSONSerialization.data(withJSONObject: talentArray, options: []),
               let talentString = String(data: talentData, encoding: .utf8) {
                formData.append(talentString.data(using: .utf8) ?? Data(),
                                withName: "talent",
                                mimeType: "application/json")
            }
        }
    }
}
