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
    private let nameTextField = UITextField()
    let nextButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = UIColor(hex: "FFF629")
        
        topBackgroundView.do {
            $0.backgroundColor = UIColor(hex: "F9AF55")
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.Name.title
            $0.textColor = .black
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Onboarding.Name.description
            $0.textColor = .black
            $0.font = .fontContacto(.caption2)
            $0.textAlignment = .center
        }
        
        nameTextField.do {
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Onboarding.Name.example, forColor: UIColor(hex: "969696"))
            $0.font = .fontContacto(.button)
            $0.textAlignment = .center
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .black, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .white
            $0.textColor = .black
            $0.returnKeyType = .done
        }
        
        nextButton.do {
            $0.setTitle(StringLiterals.Onboarding.Name.button, for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button)
            $0.setBackgroundColor(UIColor(hex: "C8C8C8"), for: .normal)
            $0.setRoundBorder(borderColor: .black, borderWidth: 1.5, cornerRadius: 0)
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
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
    }
}
