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
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for _: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        case 401:
            requestsToRetry.append(completion)
            if !isRefreshingToken {
                isRefreshingToken = true
                refreshToken { [weak self] isSuccess in
                    guard let self = self else { return }
                    
                    self.isRefreshingToken = false
                    self.requestsToRetry.forEach { $0(isSuccess ? .retry : .doNotRetry) }
                    self.requestsToRetry.removeAll()
                }
            }
        default:
            completion(.doNotRetry)
        }
    }
    
    func refreshToken(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.reissue() { [weak self] result in
            guard let self else {return}
            switch result {
            case .success(let data):
                KeychainHandler.shared.refreshToken = data.refreshToken
                KeychainHandler.shared.accessToken = data.accessToken
                completion(true)
                return
            case .failure:
                self.logout()
            default:
                completion(false)
                self.logout()
            }
        }
    }
    
    func logout() {
        KeychainHandler.shared.logout()
        DispatchQueue.main.async {
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }
    }
}
