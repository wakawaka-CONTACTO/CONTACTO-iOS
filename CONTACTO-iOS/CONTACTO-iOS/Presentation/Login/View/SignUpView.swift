//
//  SignUpView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/30/24.
//

import UIKit

import SnapKit
import Then

final class SignUpView: BaseView {
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    let mainTextField = LoginBaseTextField(state: .email)
    let privacyAgreeButton = UIButton()
    let privacyAgreeTitle = UILabel()
    let privacyAgreeDetailButton = UIButton()
    let continueButton = UIButton()
    let backButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.signUp
            $0.font = .fontContacto(.caption1)
            $0.textColor = .ctwhite
        }
        
        privacyAgreeButton.do {
            $0.setImage(.icNotChecked, for: .normal)
        }
        
        privacyAgreeTitle.do {
            $0.text = StringLiterals.Login.agreePrivacy
            $0.font = .fontContacto(.gothicSubButton)
            $0.textColor = .ctwhite
        }
        
        privacyAgreeDetailButton.do {
            $0.setTitle(StringLiterals.Login.detailButton, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicSubButton)
            $0.setTitleColor(.ctwhite, for: .normal)
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.continueButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.isEnabled = false
        }
        
        backButton.do {
            $0.setTitle(StringLiterals.Login.backToLogin, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    mainTextField,
                    privacyAgreeButton,
                    privacyAgreeTitle,
                    privacyAgreeDetailButton,
                    continueButton,
                    backButton)
        
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
        
        privacyAgreeButton.snp.makeConstraints {
            $0.leading.equalTo(mainTextField)
            $0.size.equalTo(15)
            $0.top.equalTo(mainTextField.snp.bottom).offset(20.adjustedHeight)
        }
        
        privacyAgreeTitle.snp.makeConstraints {
            $0.centerY.equalTo(privacyAgreeButton)
            $0.leading.equalTo(privacyAgreeButton.snp.trailing).offset(9)
        }
        
        privacyAgreeDetailButton.snp.makeConstraints {
            $0.centerY.equalTo(privacyAgreeButton)
            $0.trailing.equalTo(mainTextField)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(privacyAgreeButton.snp.bottom).offset(13.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        backButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(continueButton.snp.bottom).offset(18.adjustedHeight)
        }
    }
}
    
