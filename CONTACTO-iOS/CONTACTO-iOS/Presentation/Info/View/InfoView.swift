//
//  InfoView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/20/24.
//

import UIKit

import SnapKit
import Then

final class InfoView: BaseView {
    
    private let topView = UIView()
    private let topImageView = UIImageView()
    
    private let accountLabel = UILabel()
    let emailButton = UIButton()
    let emailLabel = UILabel()
    let passwordButton = UIButton()
    let passwordLabel = UILabel()
    
    let helpButton = UIButton()
    let guidelinesButton = UIButton()
    let cookieButton = UIButton()
    
    private let logoImageView = UIImageView()
    let versionLabel = UILabel()
    
    let logoutButton = UIButton()
    let deleteButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctsubyellow1
        
        topView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = .imgEditTopLogo
            $0.contentMode = .scaleAspectFit
        }
        
        accountLabel.do {
            $0.text = StringLiterals.Info.account
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button8)
        }
        
        emailButton.do {
            $0.setTitle(StringLiterals.Info.email, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctgray3, for: .normal)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.isEnabled = false
            $0.titleLabel?.textAlignment = .left
        }
        
        emailLabel.do {
            $0.text = "contacto@wakawaka.kr"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button1)
        }
        
        passwordButton.do {
            $0.setTitle(StringLiterals.Info.password, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctgray3, for: .normal)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.isEnabled = false
            $0.titleLabel?.textAlignment = .left
        }
        
        passwordLabel.do {
            $0.text = "********"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button1)
        }
        
        helpButton.do {
            $0.setTitle(StringLiterals.Info.help, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.titleLabel?.textAlignment = .left
        }
        
        guidelinesButton.do {
            $0.setTitle(StringLiterals.Info.guidelines, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.titleLabel?.textAlignment = .left
        }
        
        cookieButton.do {
            $0.setTitle(StringLiterals.Info.privacy, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctsubgreen2, for: .normal)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.titleLabel?.textAlignment = .left
        }
        
        logoImageView.do {
            $0.image = .imgInfoLogo
        }
        
        versionLabel.do {
            $0.text = "v 1.0.0"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption2)
        }
        
        logoutButton.do {
            $0.setTitle(StringLiterals.Info.logout, for: .normal)
            $0.setTitleColor(.ctgray3, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
        }
        
        deleteButton.do {
            $0.setTitle(StringLiterals.Info.delete, for: .normal)
            $0.setTitleColor(.ctgray3, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
        }
    }
    
    override func setLayout() {
        addSubviews(topView,
                    accountLabel,
                    emailButton,
                    passwordButton,
                    helpButton,
                    guidelinesButton,
                    cookieButton,
                    logoImageView,
                    versionLabel,
                    logoutButton,
                    deleteButton)
        topView.addSubviews(topImageView)
        emailButton.addSubviews(emailLabel)
        passwordButton.addSubviews(passwordLabel)
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(98.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        accountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.top.equalTo(topView.snp.bottom).offset(24)
        }
        
        emailButton.snp.makeConstraints {
            $0.top.equalTo(accountLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(34)
        }
        
        emailButton.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        }
        
        passwordButton.snp.makeConstraints {
            $0.top.equalTo(emailButton.snp.bottom).offset(5)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        passwordButton.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(7)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(passwordButton.snp.bottom).offset(5)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        helpButton.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        guidelinesButton.snp.makeConstraints {
            $0.top.equalTo(helpButton.snp.bottom).offset(5)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        guidelinesButton.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        cookieButton.snp.makeConstraints {
            $0.top.equalTo(guidelinesButton.snp.bottom).offset(5)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        cookieButton.titleLabel?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(cookieButton.snp.bottom).offset(58)
        }
        
        versionLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints {
            $0.leading.equalTo(emailButton)
            $0.bottom.equalToSuperview().inset(17)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(emailButton)
            $0.bottom.equalTo(logoutButton)
        }
    }
}
