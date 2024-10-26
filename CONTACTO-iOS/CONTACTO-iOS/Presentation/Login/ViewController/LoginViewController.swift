//
//  LoginViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import AuthenticationServices
import SnapKit
import Then

final class LoginViewController: BaseViewController {
    
    private let loginView = LoginView()
    
    override func setLayout() {
        view.addSubviews(loginView)
        
        loginView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        loginView.continueButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        loginView.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        loginView.helpButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        loginView.privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        let onboardingViewController = NameOnboardingViewController()
        self.navigationController?.pushViewController(onboardingViewController, animated: true)
    }
    
    @objc func appleLoginButtonTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let requset = provider.createRequest()
        requset.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [requset])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc private func privacyButtonTapped() {
        guard let url = URL(string: "https://naver.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         self.view.window ?? UIWindow()
     }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("로그인 실패", error.localizedDescription)
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            let identityToken = appleIdCredential.identityToken
            let authorizationCode = appleIdCredential.authorizationCode
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("사용자 ID: \(userIdentifier)")
            print("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("이메일: \(email ?? "")")
            print("Token: \(identityToken!)")
            print("authorizationCode: \(authorizationCode!)")
            
            buttonTapped()
            
        // 암호 기반 인증에 성공한 경우(iCloud), 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
        case let passwordCredential as ASPasswordCredential:
            let userIdentifier = passwordCredential.user
            let password = passwordCredential.password
            
            print("암호 기반 인증에 성공하였습니다.")
            print("사용자 이름: \(userIdentifier)")
            print("비밀번호: \(password)")
            
            buttonTapped()
            
        default: break
            
        }
    }
}
