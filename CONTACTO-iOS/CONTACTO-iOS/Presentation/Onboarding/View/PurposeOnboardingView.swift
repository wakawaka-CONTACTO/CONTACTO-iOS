//
//  PurposeOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class PurposeOnboardingView: BaseView {
    
    var selectedPurpose: [Int] = []
    var selectedCount = 0 {
        didSet {
            nextButton.isEnabled = (selectedCount != 0)
        }
    }
    
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    let getButton = OnboardingPurposeButton(num: 0)
    let collaboButton = OnboardingPurposeButton(num: 1)
    let makeButton = OnboardingPurposeButton(num: 2)
    let artButton = OnboardingPurposeButton(num: 3)
    let groupButton = OnboardingPurposeButton(num: 4)
    
    let nextButton = OnboardingNextButton(count: 2)
    
    override func setAddTarget() {
        [getButton, collaboButton, makeButton, artButton, groupButton].forEach {
            $0.addTarget(self, action: #selector(purposeButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    override func setStyle() {
        self.backgroundColor = .ctmainblue
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Purpose.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Onboarding.Purpose.description
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption2)
            $0.textAlignment = .center
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    descriptionLabel,
                    getButton,
                    collaboButton,
                    makeButton,
                    artButton,
                    groupButton,
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
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55.adjustedHeight)
            $0.trailing.equalToSuperview().inset(16.adjustedWidth)
        }
        
        getButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        collaboButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(getButton)
            $0.top.equalTo(getButton.snp.bottom).offset(16.adjustedHeight)
        }
        
        makeButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(getButton)
            $0.top.equalTo(collaboButton.snp.bottom).offset(16.adjustedHeight)
        }
        
        artButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(getButton)
            $0.top.equalTo(makeButton.snp.bottom).offset(16.adjustedHeight)
        }
        
        groupButton.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(getButton)
            $0.top.equalTo(artButton.snp.bottom).offset(16.adjustedHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
        }
    }
    
    @objc private func purposeButtonTapped(_ sender: OnboardingPurposeButton) {
        selectedCount = 0
        sender.buttonTapped()
        [getButton, collaboButton, makeButton, artButton, groupButton].forEach {
            if $0.isTapped {
                selectedCount += 1
                selectedPurpose.append($0.num)
            }
        }
    }
}
