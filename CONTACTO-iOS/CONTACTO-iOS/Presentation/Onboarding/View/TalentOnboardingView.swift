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
            $0.text = StringLiterals.Onboarding.SNS.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
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
    }
}
