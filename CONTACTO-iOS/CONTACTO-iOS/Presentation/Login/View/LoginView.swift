//
//  LoginView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then

@frozen enum loginState {
    case email
    case emailError
    case emailForget
    case pw
    case pwError
    case pwForget
    case findEmail
}

final class LoginView: BaseView {
    
    var state = loginState.email
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let explain = UILabel()
    let mainTextField = LoginBaseTextField(state: .email)
    let continueButton = UIButton()
    let newAccountButton = UIButton()
    let forgetEmailButton = UIButton()
    let forgetPwButton = UIButton()
    let helpButton = UIButton()
    let privacyButton = UIButton()
    let backButton = UIButton()
    init(state: loginState) {
        super.init(frame: CGRect())
        setLoginState(state: state)
    }
    
    override func setAddTarget() {
        mainTextField.eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
    }
    
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
        
        explain.do {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.font = .fontContacto(.caption9)
            $0.textColor = .ctwhite
            $0.textAlignment = .center
        }
        
        continueButton.do {
            $0.setTitle(StringLiterals.Login.continueButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.isEnabled = false
        }
        
        forgetPwButton.do {
            $0.setTitle(StringLiterals.Login.forgetPwButton, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
        }
        
        forgetEmailButton.do {
            $0.setTitle(StringLiterals.Login.forgetEmailButton, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
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
        
        backButton.do {
            $0.setTitle(StringLiterals.Login.firstStepButton, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
        }
    }
    
    override func setLayout() {
        addSubviews(logoImageView,
                    descriptionLabel,
                    explain,
                    mainTextField,
                    continueButton,
                    forgetPwButton,
                    forgetEmailButton,
                    newAccountButton,
                    backButton,
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
        
        explain.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(2.adjustedHeight)
            $0.centerX.equalToSuperview()
            $0.height.lessThanOrEqualTo(34.adjustedHeight)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(explain.snp.bottom).offset(25.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10.5.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        forgetPwButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(19.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        forgetEmailButton.snp.makeConstraints {
            $0.center.equalTo(forgetPwButton)
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
        
        backButton.snp.makeConstraints {
            $0.center.equalTo(helpButton)
        }
        
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(helpButton.snp.bottom).offset(15.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setLoginState(state: loginState) {
        self.state = state
        switch state {
        case .email:
            newAccountButton.isHidden = false
            helpButton.isHidden = false
            privacyButton.isHidden = false
            forgetPwButton.isHidden = true
            backButton.isHidden = true
            mainTextField.setTextFieldState(state: .email)
            continueButton.setTitle(StringLiterals.Login.continueButton, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.login
            explain.text = ""
            mainTextField.isError = false
            forgetEmailButton.isHidden = true
            mainTextField.eyeButton.isHidden = true
            
        case .emailError:
            newAccountButton.isHidden = true
            helpButton.isHidden = false
            privacyButton.isHidden = false
            forgetPwButton.isHidden = true
            backButton.isHidden = true
            mainTextField.setTextFieldState(state: .email)
            continueButton.setTitle(StringLiterals.Login.continueButton, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.noAccountTitle
            explain.text = "THERE’S NO CONTACTO ACCOUNT WITH THE INFO YOU PROVIDED. \n PLEASE INPUT CORRECT E-MAIL OR CLICK BELOW HELP BUTTON."
            mainTextField.isError = true
            forgetEmailButton.isHidden = false
            mainTextField.eyeButton.isHidden = true


        case .pw:
            newAccountButton.isHidden = true
            helpButton.isHidden = true
            privacyButton.isHidden = true
            forgetPwButton.isHidden = false
            backButton.isHidden = false
            mainTextField.setTextFieldState(state: .pw)
            explain.text = ""
            self.bringSubviewToFront(mainTextField.eyeButton)
            continueButton.setTitle(StringLiterals.Login.login, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.login
            mainTextField.isError = false
            forgetEmailButton.isHidden = true
            
        case .pwError:
            newAccountButton.isHidden = true
            helpButton.isHidden = true
            privacyButton.isHidden = true
            forgetPwButton.isHidden = false
            backButton.isHidden = false
            mainTextField.setTextFieldState(state: .pw)
            self.bringSubviewToFront(mainTextField.eyeButton)
            continueButton.setTitle(StringLiterals.Login.login, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.incorrectPWTitle
            explain.text = "PLEASE INPUT CORRECT PASSWORD OR CLICK BELOW HELP BUTTON."
            mainTextField.isError = true
            forgetEmailButton.isHidden = true
            
        case .emailForget:
            newAccountButton.isHidden = true
            helpButton.isHidden = true
            privacyButton.isHidden = true
            forgetPwButton.isHidden = false
            backButton.isHidden = false
            mainTextField.setTextFieldState(state: .name)
            continueButton.setTitle(StringLiterals.Login.continueButton, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.inputName
            mainTextField.isError = false
            forgetEmailButton.isHidden = true
            mainTextField.eyeButton.isHidden = true
            
        case .pwForget:
            newAccountButton.isHidden = true
            helpButton.isHidden = true
            privacyButton.isHidden = true
            forgetPwButton.isHidden = true
            backButton.isHidden = false
            mainTextField.setTextFieldState(state: .email)
            continueButton.setTitle(StringLiterals.Login.continueButton, for: .normal)
            continueButton.isEnabled = false
            descriptionLabel.text = StringLiterals.Login.sendCode
            mainTextField.isError = false
            forgetEmailButton.isHidden = true
            
        case .findEmail:
            newAccountButton.isHidden = true
            helpButton.isHidden = true
            privacyButton.isHidden = true
            forgetPwButton.isHidden = false
            backButton.isHidden = true
            mainTextField.setTextFieldState(state: .findEmail)
            continueButton.setTitle(StringLiterals.Login.goToLogin, for: .normal)
            continueButton.isEnabled = true
            descriptionLabel.text = StringLiterals.Login.yourEmail
            mainTextField.isError = false
            forgetEmailButton.isHidden = true
            mainTextField.eyeButton.isHidden = true
        }
    }
    
    @objc func eyeButtonTapped() {
        guard state == .pw || state == .pwError else { return }
        
        mainTextField.isButtonTapped.toggle()
        mainTextField.isSecureTextEntry = !mainTextField.isButtonTapped
        mainTextField.eyeButton.setImage(mainTextField.isButtonTapped ? .icEyeHide : .icEye, for: .normal)
    }
}
