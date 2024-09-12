//
//  ExplainOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class ExplainOnboardingView: BaseView {
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    let explainTextView = UITextView()
    let nextButton = OnboardingNextButton(count: 3)
    
    override func setStyle() {
        self.backgroundColor = .ctsubyellow3
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Explain.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        explainTextView.do {
            $0.text = StringLiterals.Onboarding.Explain.example
            $0.textColor = .ctgray2
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.layer.borderColor = UIColor.ctblack.cgColor
            $0.layer.borderWidth = 1.5
            $0.backgroundColor = .ctwhite
            $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    explainTextView,
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
        
        explainTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.height.equalTo(150.adjustedHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
        }
    }
}
