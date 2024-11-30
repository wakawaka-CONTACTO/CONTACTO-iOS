//
//  EmailCodeView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/30/24.
//

import UIKit

import SnapKit
import Then

final class EmailCodeView: BaseView {
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    let mainTextField = UITextField()
    let underLineView = UIImageView()
    let continueButton = UIButton()
    let resendButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.verify
            $0.font = .fontContacto(.caption1)
            $0.textColor = .ctwhite
        }
        
        mainTextField.do {
            $0.font = .fontContacto(.number)
            $0.textColor = .ctwhite
            $0.textAlignment = .left
            $0.backgroundColor = .clear
            $0.keyboardType = .numberPad
            $0.returnKeyType = .done
            $0.addPadding(left: 1)
        }
        
        underLineView.do {
            $0.image = .imgUnderLine
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.nextButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.isEnabled = false
        }
        
        resendButton.do {
            $0.setTitle(StringLiterals.Login.backToLogin, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    mainTextField,
                    underLineView,
                    continueButton,
                    resendButton)
        
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(153.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(23.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        underLineView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(mainTextField)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(25.adjustedHeight)
            $0.leading.trailing.equalTo(underLineView).inset(15)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(underLineView.snp.bottom).offset(13.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        resendButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(continueButton.snp.bottom).offset(18.adjustedHeight)
        }
    }
}
    
