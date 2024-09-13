//
//  PortfolioOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class PortfolioOnboardingView: BaseView {
    
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    
    lazy var portfolioCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: portfolioFlowLayout
    )
    private let portfolioFlowLayout = UICollectionViewFlowLayout()
    
    let nextButton = OnboardingNextButton(count: 6)
    
    override func setStyle() {
        self.backgroundColor = .ctblack
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Portfolio.title
            $0.textColor = .ctwhite
            $0.font = .fontContacto(.title2)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        portfolioCollectionView.do {
            $0.backgroundColor = .clear
            $0.contentInset = UIEdgeInsets(top: 0, left: 16.5, bottom: 0, right: 16.5)
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        portfolioFlowLayout.do {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 15
            $0.estimatedItemSize = CGSize(width: 306, height: 306)
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    portfolioCollectionView,
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
            $0.top.equalTo(topImageView.snp.bottom).offset(46.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
        }
        
        portfolioCollectionView.snp.makeConstraints {
            $0.height.equalTo(306)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-50.adjustedHeight)
        }
    }
}
