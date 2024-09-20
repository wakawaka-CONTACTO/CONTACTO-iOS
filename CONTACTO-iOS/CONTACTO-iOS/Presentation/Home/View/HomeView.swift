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
    private let topView = UIView()
    private let icCImageView = UIImageView()
    private let icTImageView = UIImageView()
    
    lazy var pageCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pageFlowLayout
    )
    private let pageFlowLayout = UICollectionViewFlowLayout()
    
    let portView = UIView()
    let backView = UIView()
    let nextView = UIView()
    let portImageView = UIImageView()
    
    let profileButton = UIButton()
    let profileTitle = UILabel()
    let profileNameLabel = UILabel()
    
    let noButton = UIButton()
    let yesButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctblack1
        
        icCImageView.do {
            $0.image = .icC
            $0.contentMode = .scaleAspectFit
        }
        
        icTImageView.do {
            $0.image = .icT
            $0.contentMode = .scaleAspectFit
        }
        
        pageCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = false
        }
        
        pageFlowLayout.do {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 13.adjustedWidth
        }
        
        portView.do {
            $0.isUserInteractionEnabled = true
            $0.clipsToBounds = true
        }
        
        portImageView.do {
            $0.contentMode = .scaleAspectFill
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
        
        self.addSubviews(topView,
                         portView,
                         noButton,
                         yesButton)
        
        topView.addSubviews(icCImageView,
                            pageCollectionView,
                            icTImageView)
        
        portView.addSubviews(portImageView,
                             backView,
                             nextView,
                             profileButton)
        
        profileButton.addSubviews(profileTitle,
                                  profileNameLabel)
        
        topView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(21)
            $0.leading.trailing.equalToSuperview().inset(12.adjustedWidth)
            $0.height.equalTo(56.adjustedHeight)
        }
        
        icCImageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.width.equalTo(46.adjustedWidth)
        }
        
        icTImageView.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.width.equalTo(46.adjustedWidth)
        }
        
        pageCollectionView.snp.makeConstraints {
            $0.leading.equalTo(icCImageView.snp.trailing).offset(6.adjustedWidth)
            $0.trailing.equalTo(icTImageView.snp.leading).offset(-6.adjustedWidth)
            $0.center.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        portView.snp.makeConstraints {
            $0.height.equalTo(492.adjustedHeight)
            $0.top.equalTo(topView.snp.bottom).offset(10.adjustedHeight)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        portImageView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        backView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(SizeLiterals.Screen.screenWidth / 2)
        }
        
        nextView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(SizeLiterals.Screen.screenWidth / 2)
        }
        
        profileButton.snp.makeConstraints {
            $0.center.equalToSuperview()
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
