//
//  ProfilePurposeCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ProfilePurposeCollectionViewCell: UICollectionViewCell {
    
    private let purposeList = [
        StringLiterals.Onboarding.Purpose.getalong,
        StringLiterals.Onboarding.Purpose.collaborate,
        StringLiterals.Onboarding.Purpose.makenew,
        StringLiterals.Onboarding.Purpose.art,
        StringLiterals.Onboarding.Purpose.group
    ]
    
    private let colorArray: [UIColor] = [.ctsubred,
                                 .ctsubpink,
                                 .ctsubblue2,
                                 .ctsubyellow2,
                                 .ctsubgreen1]
    
    let purposeLabel = UILabel()
    
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
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.2, cornerRadius: 0)
        }
        
        purposeLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button6)
        }
    }
    
    private func setLayout() {
        self.addSubviews(purposeLabel)
        
        purposeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(4)
        }
    }
    
    func config(num: Int) {
        self.backgroundColor = colorArray[num]
        purposeLabel.text = purposeList[num]
    }
}
