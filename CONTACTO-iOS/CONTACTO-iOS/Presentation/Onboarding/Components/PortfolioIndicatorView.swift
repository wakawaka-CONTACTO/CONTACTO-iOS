//
//  PortfolioIndicatorView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class PortfolioIndicatorView: BaseView {
    
    let trackView = UIView()
    let trackTintView = UIView()
    
    override func setStyle() {
        self.clipsToBounds = true
        
        trackView.do {
            $0.backgroundColor = .ctgrayyellow
            $0.alpha = 0.1
            $0.setRoundBorder(borderColor: .clear, borderWidth: 0, cornerRadius: 1.5)
        }
        
        trackTintView.do {
            $0.backgroundColor = .ctgrayyellow
            $0.setRoundBorder(borderColor: .clear, borderWidth: 0, cornerRadius: 1.5)
        }
    }
    
    override func setLayout() {
        self.addSubviews(trackView,
                         trackTintView)
        
        trackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(3)
        }
        
        trackTintView.snp.makeConstraints {
            $0.width.equalTo(45)
            $0.top.bottom.height.leading.equalTo(trackView)
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}
