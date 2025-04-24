//
//  EmailVerificationManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/22/25.
//

import Foundation

final class EmailVerificationManager {
    static let shared = EmailVerificationManager()
    
    private let queue = DispatchQueue(label: "com.contacto.EmailVerificationManager")
    
    enum VerificationPurpose {
        case signup
        case resetPassword
        case changePassword
    }
    
    private var currentPurpose: VerificationPurpose?
    private var email: String = ""
    private var authCode: String = ""
    private var failCount: Int = 0
    
    var isFirstAttempt: Bool {
        return failCount == 0
    }
    
    func startVerification(email: String, purpose: VerificationPurpose, completion: @escaping (Bool, String?) -> Void) {
        queue.sync {
            self.email = email
            self.currentPurpose = purpose
            self.failCount = 0
        }
        
        sendVerificationEmail(completion: completion)
    }
    
    func verifyCode(_ code: String, completion: @escaping (Bool, String?) -> Void) {
        self.authCode = code
        
        NetworkService.shared.onboardingService.emailCheck(
            bodyDTO: EmailCheckRequestBodyDTO(email: email, authCode: code)
        ) { [weak self] response in
            switch response {
            case .success(let data):
                completion(data.isSuccess, nil)
            case .failure(let error):
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data) {
                    let translatedMessage = ErrorCodeTranslator.shared.translate(errorResponse.code)
                    self?.failCount += 1
                    completion(false, translatedMessage)
                } else {
                    self?.failCount += 1
                    completion(false, "알 수 없는 오류가 발생했습니다.")
                }
            case _:
                self?.failCount += 1
                completion(false, "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    func resendVerificationEmail(completion: @escaping (Bool, String?) -> Void) {
        failCount += 1
        sendVerificationEmail(completion: completion)
    }
    
    private func sendVerificationEmail(completion: @escaping (Bool, String?) -> Void) {
        guard let purpose = currentPurpose else {
            completion(false, "인증 목적이 설정되지 않았습니다.")
            return
        }
        
        let emailPurpose: EmailSendPurpose = {
            switch purpose {
            case .signup:
                return .signup
            case .resetPassword, .changePassword:
                return .reset
            }
        }()
        
        NetworkService.shared.onboardingService.emailSend(
            bodyDTO: EmailSendRequestBodyDTO(email: email, purpose: emailPurpose)
        ) { [weak self] response in
            switch response {
            case .success:
                completion(true, nil)
            case .failure(let error):
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data) {
                    let translatedMessage = ErrorCodeTranslator.shared.translate(errorResponse.code)
                    self?.failCount += 1
                    completion(false, translatedMessage)
                } else {
                    self?.failCount += 1
                    completion(false, "알 수 없는 오류가 발생했습니다.")
                }
            case _:
                self?.failCount += 1
                completion(false, "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    func reset() {
        currentPurpose = nil
        email = ""
        authCode = ""
        failCount = 0
    }
}
