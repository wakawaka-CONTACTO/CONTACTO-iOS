//
//  NameOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then

final class NameOnboardingView: BaseView {
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    let nameTextField = UITextField()
    let nextButton = OnboardingNextButton(count: 1)
    
    override func setStyle() {
        self.backgroundColor = .ctsubyellow1
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Name.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Onboarding.Name.description
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption2)
            $0.textAlignment = .center
        }
        
        nameTextField.do {
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Onboarding.Name.example, forColor: .ctgray2)
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .center
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctwhite
            $0.textColor = .ctblack
            $0.returnKeyType = .done
            $0.autocapitalizationType = .none
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    descriptionLabel,
                    nameTextField,
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
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
        }
    }
}
