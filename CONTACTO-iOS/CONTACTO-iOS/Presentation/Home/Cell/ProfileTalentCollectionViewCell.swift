//
//  ProfileTalentCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import SnapKit
import Then

final class ProfileTalentCollectionViewCell: UICollectionViewCell {
    
    let talentLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 0.85, cornerRadius: 0)
        }
        
        talentLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button5)
        }
    }
    
    private func setLayout() {
        self.addSubviews(talentLabel)
        
        talentLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.leading.trailing.equalToSuperview().inset(3)
        }
    }
}
