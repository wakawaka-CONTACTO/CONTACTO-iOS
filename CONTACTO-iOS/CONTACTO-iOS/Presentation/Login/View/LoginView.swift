//
//  LoginView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then

final class LoginView: BaseView {
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    lazy var emailTextField = BaseTextField()
    lazy var passwordTextField = BaseTextField()
    lazy var continueButton = UIButton()
    lazy var helpButton = UIButton()
    lazy var privacyButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.title
            $0.font = .fontContacto(.caption1)
            $0.textColor = .ctwhite
        }
        
        emailTextField.do {
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.email, forColor: .ctgray2)
            $0.textAlignment = .center
            $0.backgroundColor = .ctwhite
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
            $0.returnKeyType = .done
        }
        
        passwordTextField.do {
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.pw, forColor: .ctgray2)
            $0.textAlignment = .center
            $0.backgroundColor = .ctwhite
            $0.keyboardType = .asciiCapable
            $0.autocapitalizationType = .none
            $0.isSecureTextEntry = true
            $0.returnKeyType = .done
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.continueButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.backgroundColor = .ctsubgreen2
        }
        
        helpButton.do {
            $0.setTitle(StringLiterals.Login.help, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)            
        }
        
        privacyButton.do {
            $0.setTitle(StringLiterals.Login.privacy, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    emailTextField,
                    passwordTextField,
                    continueButton,
                    helpButton,
                    privacyButton)
        
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(153.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(23.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(25.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(7.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(45.adjustedHeight)
            $0.leading.trailing.equalTo(emailTextField)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(91.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(helpButton.snp.bottom).offset(15.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
