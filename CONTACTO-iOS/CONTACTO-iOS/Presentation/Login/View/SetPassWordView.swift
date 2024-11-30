//
//  SetPassWordView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/30/24.
//

import UIKit

import SnapKit
import Then

final class SetPassWordView: BaseView {
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    let mainTextField = LoginBaseTextField(state: .pw)
    let conditionViewLetter = PasswordConditionView(state: .letter)
    let conditionViewSpecial = PasswordConditionView(state: .special)
    let conditionViewNum = PasswordConditionView(state: .num)
    let confirmTextField = LoginBaseTextField(state: .pw)
    let continueButton = UIButton()
    
    override func setStyle() {
        logoImageView.do {
            $0.image = UIImage(resource: .loginLogo)
            $0.contentMode = .scaleAspectFit
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Login.setPW
            $0.font = .fontContacto(.caption1)
            $0.textColor = .ctwhite
        }
        
        confirmTextField.do {
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.confirmPW, forColor: .ctgray2)
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.nextButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.isEnabled = false
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    mainTextField,
                    conditionViewLetter,
                    conditionViewSpecial,
                    conditionViewNum,
                    confirmTextField,
                    continueButton)
        
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
        
        conditionViewLetter.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(7)
            $0.leading.equalToSuperview().inset(44.adjustedWidth)
        }
        
        conditionViewSpecial.snp.makeConstraints {
            $0.top.equalTo(conditionViewLetter.snp.bottom)
            $0.leading.equalTo(conditionViewLetter)
        }
        
        conditionViewNum.snp.makeConstraints {
            $0.top.equalTo(conditionViewSpecial.snp.bottom)
            $0.leading.equalTo(conditionViewSpecial)
        }
        
        confirmTextField.snp.makeConstraints {
            $0.top.equalTo(conditionViewNum.snp.bottom).offset(12.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(confirmTextField.snp.bottom).offset(13.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
    }
}
    
