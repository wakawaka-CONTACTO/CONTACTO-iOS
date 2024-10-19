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
    
    let contactLabel = UILabel()
    let helpButton = UIButton()
    
    let communityLabel = UILabel()
    let guidelinesButton = UIButton()
    
    let privacyLabel = UILabel()
    let cookieButton = UIButton()
    
    let logoImageView = UIImageView()
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
        
        contactLabel.do {
            $0.text = StringLiterals.Info.contact
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button8)
        }
        
        helpButton.do {
            $0.setTitle(StringLiterals.Info.help, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctwhite, for: .normal)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.titleLabel?.textAlignment = .left
        }
        
        communityLabel.do {
            $0.text = StringLiterals.Info.community
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button8)
        }
        
        guidelinesButton.do {
            $0.setTitle(StringLiterals.Info.guidelines, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctwhite, for: .normal)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.titleLabel?.textAlignment = .left
        }
        
        privacyLabel.do {
            $0.text = StringLiterals.Info.community
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button8)
        }
        
        cookieButton.do {
            $0.setTitle(StringLiterals.Info.cookie, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.setBackgroundColor(.ctwhite, for: .normal)
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
                    contactLabel,
                    helpButton,
                    communityLabel,
                    guidelinesButton,
                    privacyLabel,
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
        
        emailLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        }
        
        passwordButton.snp.makeConstraints {
            $0.top.equalTo(emailButton.snp.bottom).offset(5)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(7)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        contactLabel.snp.makeConstraints {
            $0.top.equalTo(passwordButton.snp.bottom).offset(15)
            $0.leading.equalTo(accountLabel)
        }
        
        helpButton.snp.makeConstraints {
            $0.top.equalTo(contactLabel.snp.bottom).offset(3)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        communityLabel.snp.makeConstraints {
            $0.top.equalTo(helpButton.snp.bottom).offset(15)
            $0.leading.equalTo(accountLabel)
        }
        
        guidelinesButton.snp.makeConstraints {
            $0.top.equalTo(communityLabel.snp.bottom).offset(3)
            $0.leading.trailing.height.equalTo(emailButton)
        }
        
        privacyLabel.snp.makeConstraints {
            $0.top.equalTo(guidelinesButton.snp.bottom).offset(15)
            $0.leading.equalTo(accountLabel)
        }
        
        cookieButton.snp.makeConstraints {
            $0.top.equalTo(privacyLabel.snp.bottom).offset(3)
            $0.leading.trailing.height.equalTo(emailButton)
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
