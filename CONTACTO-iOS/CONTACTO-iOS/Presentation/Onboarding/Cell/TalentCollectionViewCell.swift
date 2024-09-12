//
//  TalentCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class TalentCollectionViewCell: UICollectionViewCell {
    
    let talentButton = UIButton()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    func setStyle() {
        titleLabel.do {
            $0.backgroundColor = .ctwhite
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 0.85, cornerRadius: 0)
            $0.textColor = .ctblack
            $0.textAlignment = .center
            $0.font = .fontContacto(.button3)
            $0.isUserInteractionEnabled = false
        }
    }
    
    func setLayout() {
        self.addSubviews(talentButton)
        talentButton.addSubviews(titleLabel)
        
        talentButton.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.width.equalTo((SizeLiterals.Screen.screenWidth - 70.adjustedWidth) / 3)
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
