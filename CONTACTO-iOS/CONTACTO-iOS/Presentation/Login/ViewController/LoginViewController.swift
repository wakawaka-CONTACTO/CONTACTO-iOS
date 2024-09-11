//
//  LoginViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

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
        loginView.appleLoginButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        loginView.helpButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        let onboardingController = NameOnboardingViewController()
        self.navigationController?.pushViewController(onboardingController, animated: true)
    }
}
