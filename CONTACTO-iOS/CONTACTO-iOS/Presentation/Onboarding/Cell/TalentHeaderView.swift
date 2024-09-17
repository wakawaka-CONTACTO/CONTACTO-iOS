//
//  TalentHeaderView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class TalentHeaderView: UICollectionReusableView {
    
    let talentTitle = UILabel()
    
    func setUI() {
        setStyle()
        setLayout()
    }
    
    func setStyle() {
        talentTitle.do {
            $0.text = StringLiterals.Onboarding.Talent.art
            $0.font = .fontContacto(.body2)
            $0.textColor = .ctblack
        }
    }
    
    func setLayout() {
        addSubviews(talentTitle)
        
        talentTitle.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
