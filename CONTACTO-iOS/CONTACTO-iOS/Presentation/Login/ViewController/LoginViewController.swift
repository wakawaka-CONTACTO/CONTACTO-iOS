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
        loginView.helpButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        loginView.privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        let onboardingViewController = NameOnboardingViewController()
        self.navigationController?.pushViewController(onboardingViewController, animated: true)
    }
    
    @objc private func privacyButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

