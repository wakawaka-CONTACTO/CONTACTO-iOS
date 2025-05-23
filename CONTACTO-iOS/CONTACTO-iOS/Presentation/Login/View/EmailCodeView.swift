//
//  EmailCodeView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/30/24.
//

import UIKit

import SnapKit
import Then

protocol EmailCodeViewDelegate: AnyObject {
    func timerDidFinish(_ view: EmailCodeView)
    func backButtonTapped()
}

final class EmailCodeView: BaseView, LoginAmplitudeSender {
    
    private let logoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    let mainTextField = UITextField()
    let underLineView = UIImageView()
    let continueButton = UIButton()
    let resendButton = UIButton()
    private let explain = UILabel()
    private var explainContents = ""
    
    private let timerLabel = UILabel()
    private var countdownTime: Int = 240
    private var timer: Timer?
    weak var delegate: EmailCodeViewDelegate?
    let backButton = UIButton()

    public func setFail(){
        explainContents = "THIS CODE IS INVALID. ENTER CORRECT CODE."
        explain.text = explainContents
    }
        
    public func setStatus(){
        explainContents = "IF you can’t see it, please check your spam folder."
        explain.text = explainContents.uppercased()
    }
    
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
            $0.setTitle(StringLiterals.Login.resendButton, for: .normal)
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.setTitleColor(.ctgray3, for: .disabled)
            $0.titleLabel?.font = .fontContacto(.gothicButton)
            $0.isEnabled = true
        }
        
        timerLabel.do {
            $0.font = .fontContacto(.caption2)
            $0.textColor = .ctwhite
            $0.textAlignment = .center
            $0.text = formatTime(countdownTime)
        }
        
        explain.do {
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.font = .fontContacto(.caption9)
            $0.textColor = .ctwhite
            $0.text = explainContents
            $0.textAlignment = .center
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
                    explain,
                    mainTextField,
                    underLineView,
                    continueButton,
                    resendButton,
                    timerLabel,
                    backButton)
        
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
        
        explain.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(2.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(explain.snp.bottom).offset(25.adjustedHeight)
            $0.leading.trailing.equalTo(underLineView).inset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(6*46.adjustedWidth)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(underLineView.snp.bottom).offset(13.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(37.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(6*30.adjustedWidth)
        }
        
        resendButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(continueButton.snp.bottom).offset(18.adjustedHeight)
        }
        
        timerLabel.snp.makeConstraints {
            $0.top.equalTo(resendButton.snp.bottom).offset(10.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(360.adjustedHeight)
        }
    }
    
    override func setAddTarget() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func backButtonDidTap() {
        delegate?.backButtonTapped()
    }
    
    func startTimer() {
        stopTimer()
        countdownTime = 240
        timerLabel.text = formatTime(countdownTime)
        resendButton.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        if countdownTime > 0 {
            countdownTime -= 1
            timerLabel.text = formatTime(countdownTime)
            if countdownTime <= 200{
                resendButton.isEnabled = true
            }
        } else {
            stopTimer()
            delegate?.timerDidFinish(self)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let sec = seconds % 60
        return String(format: "%02d:%02d", minutes, sec)
    }
}
    
