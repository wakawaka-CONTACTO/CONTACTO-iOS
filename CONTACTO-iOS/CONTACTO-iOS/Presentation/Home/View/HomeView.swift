//
//  HomeView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class HomeView: BaseView {
    private let topImageView = UIImageView()
    
    let portImageView = UIImageView()
    
    let profileButton = UIButton()
    let profileTitle = UILabel()
    let profileNameLabel = UILabel()
    
    let noButton = UIButton()
    let yesButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctblack
        
        topImageView.do {
            $0.image = .imgHomeTop
            $0.contentMode = .scaleAspectFill
        }
        
        portImageView.do {
            $0.image = .imgex
            $0.contentMode = .scaleAspectFit
        }
        
        profileButton.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctmainblue, for: .normal)
        }
        
        profileTitle.do {
            $0.text = StringLiterals.Home.Main.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption6)
            $0.textAlignment = .center
        }
        
        profileNameLabel.do {
            $0.text = "abcdefg"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
            $0.textAlignment = .center
        }
        
        noButton.do {
            $0.setImage(.icX, for: .normal)
        }
        
        yesButton.do {
            $0.setImage(.icO, for: .normal)
        }
    }
    
    override func setLayout() {
        
        self.addSubviews(topImageView,
                         portImageView,
                         profileButton,
                         noButton,
                         yesButton)
        
        profileButton.addSubviews(profileTitle,
                                  profileNameLabel)
        
        topImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(47.adjustedHeight)
        }
        
        portImageView.snp.makeConstraints {
            $0.height.equalTo(492.adjustedHeight)
            $0.top.equalTo(topImageView.snp.bottom).offset(4.adjustedHeight)
            $0.leading.trailing.equalToSuperview()
        }
        
        profileButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(topImageView.snp.bottom).offset(248.adjustedHeight)
            $0.height.equalTo(48.adjustedHeight)
            $0.width.equalTo(212.adjustedWidth)
        }
        
        profileTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(3.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(3.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        noButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        yesButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(noButton)
        }
        
        
    }
}
