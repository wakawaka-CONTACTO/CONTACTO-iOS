//
//  ChatRoomYourCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/21/24.
//

import UIKit

import SnapKit
import Then

final class ChatRoomYourCollectionViewCell: UICollectionViewCell {
    let myMessageLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    let timeLabel = UILabel()
    
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
        myMessageLabel.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctsubyellow2
            $0.font = .fontContacto(.caption8)
            $0.text = "Welcome to Contacto! If you have a problem using  contacto, you can chat anytime this room."
            $0.textAlignment = .left
            $0.lineBreakMode = .byCharWrapping
            $0.textColor = .ctblack
            $0.numberOfLines = 0
        }
        
        timeLabel.do {
            $0.text = "22:39"
            $0.font = .fontContacto(.caption9)
            $0.textColor = .ctblack
        }
    }
    
    private func setLayout() {
        self.addSubviews(myMessageLabel,
                         timeLabel)
        
        myMessageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
            $0.width.lessThanOrEqualTo(230)
            $0.height.equalTo(27).priority(999)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(myMessageLabel.snp.trailing).offset(3)
            $0.bottom.equalTo(myMessageLabel)
        }
    }
}
