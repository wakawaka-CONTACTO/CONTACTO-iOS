//
//  EmailVerificationManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/22/25.
//

import Foundation
import UIKit

final class EmailVerificationManager {
    static let shared = EmailVerificationManager()
    
    private init() {}
    
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
    
    func startVerification(email: String, purpose: VerificationPurpose, completion: @escaping (Bool) -> Void) {
        self.email = email
        self.currentPurpose = purpose
        self.failCount = 0
        
        sendVerificationEmail(completion: completion)
    }
    
    func verifyCode(_ code: String, completion: @escaping (Bool) -> Void) {
        self.authCode = code
        
        NetworkService.shared.onboardingService.emailCheck(
            bodyDTO: EmailCheckRequestBodyDTO(email: email, authCode: code)
        ) { [weak self] response in
            switch response {
            case .success(let data):
                completion(data.isSuccess)
            default:
                self?.failCount += 1
                completion(false)
            }
        }
    }
    
    func resendVerificationEmail(completion: @escaping (Bool) -> Void) {
        failCount += 1
        sendVerificationEmail(completion: completion)
    }
    
    private func sendVerificationEmail(completion: @escaping (Bool) -> Void) {
        guard let purpose = currentPurpose else {
            completion(false)
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
                completion(true)
            case .failure(let error):
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data) {
                    DispatchQueue.main.async {
                        if let window = UIApplication.shared.windows.first,
                           let rootViewController = window.rootViewController {
                            let translatedMessage = ErrorCodeTranslator.shared.translate(errorResponse.code)
                            rootViewController.showToast(message: translatedMessage)
                        }
                    }
                }
                self?.failCount += 1
                completion(false)
            default:
                self?.failCount += 1
                completion(false)
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
