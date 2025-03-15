//
//  ProfileImageCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ProfileImageCollectionViewCell: UICollectionViewCell {
    let portView = UIView()
    let portImageView = UIImageView()
    
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
        self.backgroundColor = .clear
        
        portView.do {
            $0.clipsToBounds = true
        }
        
        portImageView.do {
            $0.contentMode = .scaleAspectFill
        }
    }
    
    private func setLayout() {
        self.addSubviews(portView)
        portView.addSubviews(portImageView)
        
        portView.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth)
            $0.height.equalTo(432)
        }
        
        portImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
