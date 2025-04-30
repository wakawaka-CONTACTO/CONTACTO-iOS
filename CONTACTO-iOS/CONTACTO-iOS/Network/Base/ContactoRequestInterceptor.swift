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
    private var retryCount = 0 // 전체 재시도 횟수 추적
    private let maxRetryCount = 3 // 최대 재시도 횟수
    
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
            // 네트워크 연결 실패 처리
            if let afError = error as? AFError,
               case .sessionTaskFailed(let sessionError) = afError,
               let urlError = sessionError as? URLError {
                switch urlError.code {
                case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
                    #if DEBUG
                    print("🔴 [Network] 네트워크 연결 실패 - 에러: \(urlError)")
                    #endif
                    
                    // 첫 요청 실패 시 토스트 메시지 표시
                    if retryCount == 0 {
                        DispatchQueue.main.async {
                            self.showNetworkErrorAlert()
                        }
                    }
                    
                    // 재시도 횟수 확인
                    if retryCount < maxRetryCount {
                        retryCount += 1
                        completion(.retryWithDelay(2.0))
                    } else {
                        completion(.doNotRetry)
                    }
                    return
                default:
                    if urlError.code.rawValue == -1004 {
                        #if DEBUG
                        print("🔴 [Network] 서버 연결 실패 - 에러: \(urlError)")
                        #endif
                        
                        // 첫 요청 실패 시 토스트 메시지 표시
                        if retryCount == 0 {
                            DispatchQueue.main.async {
                                self.showNetworkErrorAlert()
                            }
                        }
                        
                        // 재시도 횟수 확인
                        if retryCount < maxRetryCount {
                            retryCount += 1
                            completion(.retryWithDelay(2.0))
                        } else {
                            completion(.doNotRetry)
                        }
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
            #if DEBUG
            print("🔴 [Token] 401 에러 발생 - URL: \(urlString)")
            #endif
            requestsToRetry.append(completion)
            
            if !isRefreshingToken {
                #if DEBUG
                print("🔄 [Token] 토큰 재발급 시작")
                #endif
                isRefreshingToken = true
                refreshToken { [weak self] isSuccess in
                    guard let self = self else { return }
                    
                    self.isRefreshingToken = false
                    #if DEBUG
                    print("✅ [Token] 토큰 재발급 완료 - 성공: \(isSuccess)")
                    
                    if isSuccess {
                        print("🔄 [Token] 실패했던 요청 재시도")
                    } else {
                        print("❌ [Token] 토큰 재발급 실패로 인한 로그아웃")
                    }
                    #endif
                    
                    if isSuccess {
                        self.requestsToRetry.forEach { $0(.retry) }
                    } else {
                        self.requestsToRetry.forEach { $0(.doNotRetry) }
                        DispatchQueue.main.async {
                            self.logout()
                        }
                    }
                    self.requestsToRetry.removeAll()
                }
            } else {
                #if DEBUG
                print("⏳ [Token] 이미 토큰 재발급 중 - 요청 대기")
                #endif
            }
        case 408, 504: // Request Timeout, Gateway Timeout
            #if DEBUG
            print("🔴 [Network] 타임아웃 발생 - URL: \(urlString)")
            #endif
            
            // 첫 요청 실패 시 토스트 메시지 표시
            if retryCount == 0 {
                DispatchQueue.main.async {
                    self.showNetworkErrorAlert()
                }
            }
            
            // 재시도 횟수 확인
            if retryCount < maxRetryCount {
                retryCount += 1
                completion(.retryWithDelay(2.0))
            } else {
                completion(.doNotRetry)
            }
            
        case 500...599: // 서버 에러
            #if DEBUG
            print("🔴 [Network] 서버 에러 발생 - 상태코드: \(response.statusCode)")
            #endif
            
            // 첫 요청 실패 시 토스트 메시지 표시
            if retryCount == 0 {
                DispatchQueue.main.async {
                    self.showNetworkErrorAlert()
                }
            }
            
            // 재시도 횟수 확인
            if retryCount < maxRetryCount {
                retryCount += 1
                completion(.retryWithDelay(2.0))
            } else {
                completion(.doNotRetry)
            }
            
        default:
            completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        #if DEBUG
        print("🔄 [Token] reissue API 호출 시작")
        #endif
        
        // 현재 저장된 refresh token 확인
        let refreshToken = KeychainHandler.shared.refreshToken
        if refreshToken.isEmpty {
            #if DEBUG
            print("❌ [Token] Refresh Token이 없음")
            #endif
            completion(false)
            return
        }
        
        NetworkService.shared.onboardingService.reissue() { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                #if DEBUG
                print("✅ [Token] reissue API 호출 성공")
                print("📝 [Token] 새로운 Access Token: \(data.accessToken.prefix(10))...")
                print("📝 [Token] 새로운 Refresh Token: \(data.refreshToken.prefix(10))...")
                #endif
                
                // 새로운 토큰 저장
                KeychainHandler.shared.refreshToken = data.refreshToken
                KeychainHandler.shared.accessToken = data.accessToken
                completion(true)
                
            case .failure(let error):
                #if DEBUG
                print("❌ [Token] reissue API 호출 실패 - 에러: \(error)")
                #endif
                // 토큰 재발급 실패 시 바로 로그아웃 처리
                DispatchQueue.main.async {
                    self.logout()
                }
                completion(false)
                
            default:
                #if DEBUG
                print("❌ [Token] reissue API 호출 실패 - 알 수 없는 에러")
                #endif
                // 토큰 재발급 실패 시 바로 로그아웃 처리
                DispatchQueue.main.async {
                    self.logout()
                }
                completion(false)
            }
        }
    }
    
    func logout() {
        #if DEBUG
        print("🚪 [Token] 로그아웃 처리 시작")
        #endif
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
    
    private func showNetworkErrorAlert() {
        #if DEBUG
        print("🔴 [Network] 네트워크 오류 발생")
        #endif
        
        DispatchQueue.main.async {
            // 토스트 메시지 표시
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                window.showToast(message: StringLiterals.Info.Alert.Session.networkErrorMessage, position: .middle)
            }
        }
    }
}
