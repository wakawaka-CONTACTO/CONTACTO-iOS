//
//  ContactoRequestInterceptor.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import UIKit

import Alamofire

final class ContactoRequestInterceptor: RequestInterceptor {
    
    private var isRefreshingToken = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        /// request 될 때마다 실행됨
        let accessToken = KeychainHandler.shared.accessToken
        var urlRequest = urlRequest
        
        // reissue API인 경우 Refreshtoken 헤더 사용
        if urlRequest.url?.path.contains("/v1/auth/reissue") == true {
            urlRequest.setValue(KeychainHandler.shared.refreshToken, forHTTPHeaderField: HTTPHeaderFieldKey.refreshtoken.rawValue)
        } else {
            urlRequest.setValue(accessToken, forHTTPHeaderField: HTTPHeaderFieldKey.authentication.rawValue)
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for _: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        case 401:
            print("🔴 [Token] 401 에러 발생 - URL: \(request.request?.url?.absoluteString ?? "unknown")")
            requestsToRetry.append(completion)
            
            if !isRefreshingToken {
                print("🔄 [Token] 토큰 재발급 시작")
                isRefreshingToken = true
                refreshToken { [weak self] isSuccess in
                    guard let self = self else { return }
                    
                    self.isRefreshingToken = false
                    print("✅ [Token] 토큰 재발급 완료 - 성공: \(isSuccess)")
                    
                    if isSuccess {
                        print("🔄 [Token] 실패했던 요청 재시도")
                        self.requestsToRetry.forEach { $0(.retry) }
                    } else {
                        print("❌ [Token] 토큰 재발급 실패로 인한 로그아웃")
                        self.requestsToRetry.forEach { $0(.doNotRetry) }
                    }
                    self.requestsToRetry.removeAll()
                }
            } else {
                print("⏳ [Token] 이미 토큰 재발급 중 - 요청 대기")
            }
        default:
            completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        print("🔄 [Token] reissue API 호출 시작")
        
        // 현재 저장된 refresh token 확인
        let refreshToken = KeychainHandler.shared.refreshToken
        if refreshToken.isEmpty {
            print("❌ [Token] Refresh Token이 없음")
            completion(false)
            return
        }
        
        NetworkService.shared.onboardingService.reissue() { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                print("✅ [Token] reissue API 호출 성공")
                print("📝 [Token] 새로운 Access Token: \(data.accessToken.prefix(10))...")
                print("📝 [Token] 새로운 Refresh Token: \(data.refreshToken.prefix(10))...")
                
                // 새로운 토큰 저장
                KeychainHandler.shared.refreshToken = data.refreshToken
                KeychainHandler.shared.accessToken = data.accessToken
                completion(true)
                
            case .failure(let error):
                print("❌ [Token] reissue API 호출 실패 - 에러: \(error)")
                self.logout()
                
            default:
                print("❌ [Token] reissue API 호출 실패 - 알 수 없는 에러")
                self.logout()
            }
        }
    }
    
    func logout() {
        print("🚪 [Token] 로그아웃 처리 시작")
        KeychainHandler.shared.logout()
        DispatchQueue.main.async {
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }
    }
}
