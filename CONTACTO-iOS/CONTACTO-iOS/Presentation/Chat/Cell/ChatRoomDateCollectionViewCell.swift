//
//  ChatRoomDateCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/21/24.
//

import UIKit

import SnapKit
import Then

final class ChatRoomDateCollectionViewCell: UICollectionViewCell {
    
    let dateLabel = UILabel()
    
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
        dateLabel.do {
            $0.text = "SEP.19.2024"
            $0.font = .fontContacto(.caption2)
            $0.textColor = .ctblack
        }
    }
    
    private func setLayout() {
        self.addSubviews(dateLabel)
        
        dateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.center.equalToSuperview()
        }
    }
}
