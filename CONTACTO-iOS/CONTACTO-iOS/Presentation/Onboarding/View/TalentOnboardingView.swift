//
//  TalentOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class TalentOnboardingView: BaseView {
    
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    
    lazy var talentCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: talentFlowLayout
    )
    private let talentFlowLayout = UICollectionViewFlowLayout()
    
    let gradientView = UIImageView()
    let nextButton = OnboardingNextButton(count: 5)
    
    override func setStyle() {
        self.backgroundColor = .ctgray4
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Talent.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        talentCollectionView.do {
            $0.backgroundColor = .clear
            $0.contentInset = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 0)
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.allowsMultipleSelection = true
        }
        
        talentFlowLayout.do {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 14.adjustedHeight
            $0.minimumInteritemSpacing = 5
            $0.sectionInset = UIEdgeInsets(top: 11, left: 0, bottom: 40, right: 0)
        }
        
        gradientView.do {
            $0.image = .imgGradient
            $0.contentMode = .scaleAspectFill
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    talentCollectionView,
                    gradientView,
                    nextButton)
        
        topBackgroundView.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.height.equalTo(145.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(26.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(18.adjustedWidth)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topImageView.snp.bottom).offset(41.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
        }
        
        gradientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton).offset(-5)
        }
        
        talentCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(30.adjustedWidth)
            $0.bottom.equalToSuperview().inset(128.adjustedHeight)
        }
    }
}
