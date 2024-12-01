//
//  HomeEmptyView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/26/24.
//

import UIKit

import SnapKit
import Then

final class HomeEmptyView: BaseView {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override func setStyle() {
        self.backgroundColor = .ctblack1
        
        titleLabel.do {
            $0.text = StringLiterals.Home.Main.emptyTitle
            $0.font = .fontContacto(.title6)
            $0.asLineHeight(.title6)
            $0.textColor = .ctmainpink
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Home.Main.emptyDescription
            $0.font = .fontContacto(.body)
            $0.textColor = .ctmainpink
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
    }
    
    override func setLayout() {
        addSubviews(titleLabel,
                    descriptionLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(134.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
    }
}
