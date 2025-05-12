//
//  ContactoRequestInterceptor.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import UIKit

import Alamofire

final class ContactoRequestInterceptor: RequestInterceptor {
    
    private let syncQueue = DispatchQueue(label: "com.contacto.requestInterceptor.sync")
    private var isRefreshingToken = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private let maxRetryCount = 2 // 요청별 최대 2번 재시도
    
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
    
     /// 네트워크 에러 시, 요청 객체의 retryCount를 보고 결정
    private func handleNetworkError(for request: Request, completion: @escaping (RetryResult) -> Void) {
        // 첫 네트워크 에러 알림은 띄워주기
        if request.retryCount == 0 {
//            DispatchQueue.main.async { self.showNetworkErrorAlert() }
        }
        
        // 요청별 retryCount 활용
        if request.retryCount < maxRetryCount {
            completion(.retryWithDelay(2.0))
        } else {
            completion(.doNotRetry)
        }
    }
    
    private func handleLogout() {
        DispatchQueue.main.async {
            self.logout()
        }
    }
    
    func retry(_ request: Request, for _: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // GET 메소드가 아닌 경우 재시도하지 않음
        if request.request?.httpMethod != "GET" {
            completion(.doNotRetry)
            return
        }
        
        // 네트워크 에러 (HTTP 응답 자체가 없는 경우)
        guard let response = request.task?.response as? HTTPURLResponse else {
            // 네트워크 연결 실패 처리
            if let afError = error as? AFError,
               case .sessionTaskFailed(let sessionError) = afError,
               let urlError = sessionError as? URLError {
                switch urlError.code {
                case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
                    handleNetworkError(for: request, completion: completion)
                    return
                default:
                    if urlError.code.rawValue == -1004 {
                        handleNetworkError(for: request, completion: completion)
                        return
                    }
                }
            }
            completion(.doNotRetryWithError(error))
            return
        }
        
        let urlString = request.request?.url?.absoluteString ?? "unknown"
        
        switch response.statusCode {
        case 401:
            syncQueue.sync {
                requestsToRetry.append(completion)
                
                if !isRefreshingToken {
                    isRefreshingToken = true
                    refreshToken { [weak self] isSuccess in
                        guard let self = self else { return }
                        
                        self.syncQueue.async {
                            self.isRefreshingToken = false
                            
                            if isSuccess {
                                self.requestsToRetry.forEach { $0(.retry) }
                            } else {
                                self.requestsToRetry.forEach { $0(.doNotRetry) }
                                self.handleLogout()
                            }
                            self.requestsToRetry.removeAll()
                        }
                    }
                }
            }
            
        case 408, 504: // Request Timeout, Gateway Timeout
            handleNetworkError(for: request, completion: completion)
            
        case 500...599: // 서버 에러
            handleNetworkError(for: request, completion: completion)
            
        default:
            completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        // 현재 저장된 refresh token 확인
        let refreshToken = KeychainHandler.shared.refreshToken
        if refreshToken.isEmpty {
            handleLogout()
            completion(false)
            return
        }
        
        NetworkService.shared.onboardingService.reissue() { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                // 새로운 토큰 저장
                KeychainHandler.shared.refreshToken = data.refreshToken
                KeychainHandler.shared.accessToken = data.accessToken
                completion(true)
                
            case .failure(let error):
                handleLogout()
                completion(false)
                
            default:
                handleLogout()
                completion(false)
            }
        }
    }
    
    func logout() {
        KeychainHandler.shared.logout()
        DispatchQueue.main.async {
            // 알림창 표시
            let alert = UIAlertController(
                title: StringLiterals.Info.Alert.Session.sessionExpiredTitle,
                message: StringLiterals.Info.Alert.Session.sessionExpiredMessage,
                preferredStyle: .alert
            )
            
            // 로그인 화면으로 이동
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            }
            
            alert.addAction(okAction)
            
            // 현재 보이는 화면에서 알림창 표시
            if let topViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                topViewController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
