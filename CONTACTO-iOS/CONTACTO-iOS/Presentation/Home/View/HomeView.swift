//
//  HomeView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit
import SnapKit
import Then
import SkeletonView

final class HomeView: BaseView, HomeAmplitudeSender {
    lazy var pageCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pageFlowLayout
    )
    private let pageFlowLayout = UICollectionViewFlowLayout()
    
    let portView = UIView()
    let backView = UIView()
    let nextView = UIView()
    let portImageView = UIImageView()
    let bottomGradientView = UIImageView()
    
    let profileButton = UIButton()
    let profileTitle = UILabel()
    let profileNameLabel = UILabel()
    
    let noButton = UIButton()
    let yesButton = UIButton()
    let undoButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctblack
        self.sendAmpliLog(eventName: EventName.VIEW_HOME)
        
        pageCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = false
        }
        
        pageFlowLayout.do {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 5.adjustedWidth
        }
        
        portView.do {
            $0.isUserInteractionEnabled = true
            $0.clipsToBounds = true
        }
        
        portImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.isSkeletonable = true
            $0.skeletonCornerRadius = 8
        }
        
        profileButton.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctmainblue, for: .normal)
        }
        
        profileTitle.do {
            $0.text = StringLiterals.Home.Main.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption6)
            $0.isSkeletonable = true
            $0.textAlignment = .center
        }
        
        profileNameLabel.do {
            $0.text = " "
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
        
        undoButton.do {
            $0.setImage(.icUndo2, for: .normal)
        }
        
        bottomGradientView.do {
            $0.image = .imgMatchGradient
            $0.contentMode = .scaleAspectFill
        }
    }
    
    override func setLayout() {
        
        self.addSubviews(profileButton,
                         pageCollectionView,
                         portView,
                         bottomGradientView,
                         noButton,
                         yesButton,
                         undoButton)
        
        portView.addSubviews(portImageView,
                             backView,
                             nextView)
        
        profileButton.addSubviews(profileTitle,
                                  profileNameLabel)
        
        profileButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(13)
            $0.leading.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(48.adjustedHeight)
        }
        
        profileTitle.snp.makeConstraints {
            $0.top.equalToSuperview().inset(3.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(3.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        pageCollectionView.snp.makeConstraints {
            $0.top.equalTo(profileButton.snp.bottom).offset(11)
            $0.leading.trailing.equalTo(profileButton)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        portView.snp.makeConstraints {
            $0.height.equalTo(SizeLiterals.Screen.screenWidth * 4/3)
            $0.top.equalTo(pageCollectionView.snp.bottom).offset(10.adjustedHeight)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        portImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalTo(profileButton)
            $0.centerX.equalToSuperview()
        }
        
        backView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(SizeLiterals.Screen.screenWidth / 2)
        }
        
        nextView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(SizeLiterals.Screen.screenWidth / 2)
        }
        
        noButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        yesButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalTo(noButton.snp.centerY)
        }
        
        undoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(noButton).inset(20)
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(yesButton.snp.top).offset(-25)
            $0.bottom.equalTo(yesButton.snp.bottom).inset(0)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    // 스켈레톤 뷰를 보여주는 메서드
    func showSkeleton() {
        portImageView.showAnimatedGradientSkeleton()
        self.profileTitle.isSkeletonable = true
    }
    
    // 스켈레톤 뷰를 숨기는 메서드
    func hideSkeleton() {
        portImageView.hideSkeleton()
        self.profileTitle.isSkeletonable = false
    }
}
