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
    let topBackgroundView = UIView()
    let topImageView = UIImageView()
    
    override func setStyle() {
        self.backgroundColor = UIColor(hex: "FFF629")
        
        topBackgroundView.do {
            $0.backgroundColor = UIColor(hex: "F9AF55")
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView)
        
        topBackgroundView.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.height.equalTo(145.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(26.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(18.adjustedWidth)
        }
    }
}
