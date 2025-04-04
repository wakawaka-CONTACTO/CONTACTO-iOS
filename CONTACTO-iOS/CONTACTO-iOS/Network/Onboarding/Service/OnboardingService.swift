//
//  OnboardingService.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

protocol OnboardingServiceProtocol {
    
    func signup(bodyDTO: SignUpRequestBodyDTO, completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void)
    
    func login(bodyDTO: LoginRequestBodyDTO, completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void)
    
    func emailCheck(bodyDTO: EmailCheckRequestBodyDTO, completion: @escaping (NetworkResult<ResetPasswordResponseDTO>) -> Void)
    
    func emailSend(bodyDTO: EmailSendRequestBodyDTO, completion: @escaping (NetworkResult<EmptyResponse>) -> Void)
    
    func signHelp(bodyDTO: SignInHelpRequestBodyDTO, completion: @escaping (NetworkResult<SignInHelpResponseDTO>) -> Void)
    
    func reissue(completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void)
    
    func emailExist(queryDTO: EmailExistRequestQueryDTO, completion: @escaping (NetworkResult<EmailExistResponseDTO>) -> Void)
    
    func updatePwd(bodyDTO: LoginRequestBodyDTO, completion: @escaping (NetworkResult<ResetPasswordResponseDTO>) -> Void)
}

final class OnboardingService: APIRequestLoader<OnboardingTarget>, OnboardingServiceProtocol {
    
    func signup(bodyDTO: SignUpRequestBodyDTO, completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void) {
        fetchData(target: .signup(bodyDTO), responseData: SignUpResponseDTO.self, completion: completion)
    }
    
    func login(bodyDTO: LoginRequestBodyDTO, completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void) {
        fetchData(target: .login(bodyDTO), responseData: SignUpResponseDTO.self, completion: completion)
    }
    
    func emailCheck(bodyDTO: EmailCheckRequestBodyDTO, completion: @escaping (NetworkResult<ResetPasswordResponseDTO>) -> Void) {
        fetchData(target: .emailCheck(bodyDTO), responseData: ResetPasswordResponseDTO.self, completion: completion)
    }
    
    func emailSend(bodyDTO: EmailSendRequestBodyDTO, completion: @escaping (NetworkResult<EmptyResponse>) -> Void) {
        fetchData(target: .emailSend(bodyDTO), responseData: EmptyResponse.self, completion: completion)
    }
    
    func signHelp(bodyDTO: SignInHelpRequestBodyDTO, completion: @escaping (NetworkResult<SignInHelpResponseDTO>) -> Void) {
        fetchData(target: .signHelp(bodyDTO), responseData: SignInHelpResponseDTO.self, completion: completion)
    }
    
    func reissue(completion: @escaping (NetworkResult<SignUpResponseDTO>) -> Void) {
        fetchData(target: .reissue, responseData: SignUpResponseDTO.self, completion: completion)
    }
    
    func emailExist(queryDTO: EmailExistRequestQueryDTO, completion: @escaping (NetworkResult<EmailExistResponseDTO>) -> Void) {
        fetchData(target: .emailExist(queryDTO), responseData: EmailExistResponseDTO.self, completion: completion)
    }
    
    func updatePwd(bodyDTO: LoginRequestBodyDTO, completion: @escaping (NetworkResult<ResetPasswordResponseDTO>) -> Void) {
        fetchData(target: .updatePwd(bodyDTO), responseData: ResetPasswordResponseDTO.self, completion: completion)
    }
}
