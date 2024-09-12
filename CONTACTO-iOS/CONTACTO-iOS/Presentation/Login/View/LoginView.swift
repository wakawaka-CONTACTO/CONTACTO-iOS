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
    lazy var emailTextField = UITextField()
    lazy var continueButton = UIButton()
    private let orLabel = UILabel()
    lazy var appleLoginButton = UIButton()
    lazy var helpButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.title
            $0.font = .fontContacto(.caption1)
            $0.textColor = .white
        }
        
        emailTextField.do {
            $0.font = .fontContacto(.button)
            $0.textColor = .black
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.email, forColor: UIColor(hex: "969696"))
            $0.textAlignment = .center
            $0.backgroundColor = .white
            $0.keyboardType = .emailAddress
            $0.autocapitalizationType = .none
            $0.returnKeyType = .done
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.continueButton, for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button)
            $0.backgroundColor = UIColor(hex: "17DB4E")
        }
        
        orLabel.do {
            $0.text = StringLiterals.Login.orLabel
            $0.font = .fontContacto(.caption1)
            $0.textColor = .white
        }
        
        appleLoginButton.do {
            $0.setTitle(StringLiterals.Login.appleButton, for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button)
            $0.backgroundColor = .white
        }
        
        helpButton.do {
            $0.setTitle(StringLiterals.Login.help, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)            
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    emailTextField,
                    continueButton,
                    orLabel,
                    appleLoginButton,
                    helpButton)
        
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
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(10.adjustedHeight)
            $0.leading.trailing.equalTo(emailTextField)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        orLabel.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(10.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(orLabel.snp.bottom).offset(10.adjustedHeight)
            $0.leading.trailing.equalTo(emailTextField)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(85.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
