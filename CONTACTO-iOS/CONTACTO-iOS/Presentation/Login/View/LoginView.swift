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
    let mainTextField = LoginBaseTextField(state: .email)
    let continueButton = UIButton()
    let newAccountButton = UIButton()
    let helpButton = UIButton()
    let privacyButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.login
            $0.font = .fontContacto(.caption1)
            $0.textColor = .ctwhite
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.continueButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.isEnabled = false
        }
        
        newAccountButton.do {
            $0.setRoundBorder(borderColor: .ctwhite, borderWidth: 1.5, cornerRadius: 0)
            $0.setTitle(StringLiterals.Login.createButton, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
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
                    mainTextField,
                    continueButton,
                    newAccountButton,
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
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(25.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10.5.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        newAccountButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(20.5.adjustedHeight)
            $0.leading.trailing.equalTo(mainTextField)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(newAccountButton.snp.bottom).offset(113.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(helpButton.snp.bottom).offset(15.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
