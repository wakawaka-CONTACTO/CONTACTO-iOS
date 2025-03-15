//
//  ChatListCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ChatListCollectionViewCell: UICollectionViewCell {
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let newLabel = UILabel()
    let divideLine = UIView()
    
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
        profileImageView.do {
            $0.setRoundBorder(borderColor: .clear, borderWidth: 0, cornerRadius: 35)
            $0.backgroundColor = .ctblack
            $0.clipsToBounds = true
        }
        
        nameLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
            $0.textAlignment = .left
        }
        
        messageLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.caption7)
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }
        
        newLabel.do {            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1, cornerRadius: 0)
            $0.backgroundColor = .ctmainblue
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
            $0.textAlignment = .center
        }
        
        divideLine.do {
            $0.backgroundColor = .ctblack
        }
    }
    
    private func setLayout() {
        self.addSubviews(profileImageView,
                         nameLabel,
                         messageLabel,
                         newLabel,
                         divideLine)
        
        self.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth)
        }
        
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(70)
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(22)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(1)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        newLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(11)
            $0.height.equalTo(24)
            $0.width.equalTo(30)
            $0.trailing.equalToSuperview().inset(26)
        }
        
        divideLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.bottom.equalToSuperview()
        }
    }
    
    func configCell(data: ChatListResponseDTO) {
        nameLabel.text = data.title
        messageLabel.text = data.latestMessageContent
        profileImageView.kfSetImage(url: data.chatRoomThumbnail)
        
        switch data.unreadMessageCount {
        case 0:
            newLabel.isHidden = true
        case 1...99:
            newLabel.isHidden = false
            newLabel.text = "+\(data.unreadMessageCount)"
        default:
            newLabel.isHidden = false
            newLabel.text = "+99"
        }
    }
}
