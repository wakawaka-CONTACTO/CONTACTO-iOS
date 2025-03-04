//
//  ChatRoomView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/21/24.
//

import UIKit

import SnapKit
import Then

final class ChatRoomView: BaseView {
    
    var isFirstChat = false {
        didSet {
            fadeoutDisclaimer()
        }
    }
    
    let topView = UIView()
    let backButton = UIButton()
    let profileImageButton = UIButton()
    let nameLabel = UILabel()
    let dividerLine = UIView()
    
    let disclaimerView = UIView()
    let disclaimerTitleLabel = UILabel()
    let disclaimerDescriptionLabel = UILabel()
    
    lazy var chatRoomCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: chatRoomFlowLayout
    )
    let chatRoomFlowLayout = UICollectionViewFlowLayout()
    
    let bottomView = UIView()
    let plusButton = UIButton()
    let messageTextView = UITextView()
    let sendButton = UIButton()
    
    func fadeoutDisclaimer() {
        if isFirstChat {
            disclaimerView.isHidden = false
            UIView.animate(withDuration: 5.0, animations: {
                self.disclaimerView.alpha = 0.0
            }, completion: { _ in
                self.disclaimerView.removeFromSuperview()
                self.isFirstChat.toggle()
            })
        }
    }
    
    override func setStyle() {
        self.backgroundColor = .ctmainpink
        
        topView.do {
            $0.backgroundColor = .ctmainpink
            $0.alpha = 0.95
        }
        
        backButton.do {
            $0.setImage(.icBack, for: .normal)
        }
        
        profileImageButton.do {
            $0.setRoundBorder(borderColor: .clear, borderWidth: 0, cornerRadius: 22.adjustedHeight)
            $0.backgroundColor = .ctblack
            $0.imageView?.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        nameLabel.do {
            $0.text = " "
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button4)
        }
        
        dividerLine.do {
            $0.backgroundColor = .ctblack
        }
        
        chatRoomCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 66.adjustedHeight, left: 0, bottom: 20.adjustedHeight, right: 0)
        }
        
        chatRoomFlowLayout.do {
            $0.scrollDirection = .vertical
            $0.minimumInteritemSpacing = 10
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        bottomView.do {
            $0.backgroundColor = .ctsubpink2
        }
        
        plusButton.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctmainblue, for: .normal)
            $0.setImage(.icPlus, for: .normal)
        }
        
        messageTextView.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctwhite
            $0.font = .fontContacto(.chat)
            $0.contentInset = UIEdgeInsets(top: 7, left: 8, bottom: 6, right: 45)
            $0.textColor = .ctblack
        }
        
        sendButton.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctmainblue, for: .normal)
            $0.setImage(.icPolygon, for: .normal)
            $0.isHidden = true
        }
        
        disclaimerView.do {
            $0.backgroundColor = .ctsubgreen2
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.isHidden = true
        }
        
        disclaimerTitleLabel.do {
            $0.text = StringLiterals.Chat.Disclaimer.title
            $0.font = .fontContacto(.title)
            $0.textColor = .ctblack
        }
        
        disclaimerDescriptionLabel.do {
            $0.text = StringLiterals.Chat.Disclaimer.description
            $0.font = .fontContacto(.subTitle)
            $0.textColor = .ctblack
        }
    }
    
    override func setLayout() {
        self.addSubviews(chatRoomCollectionView,
                         topView,
                         bottomView,
                         disclaimerView)
        
        topView.addSubviews(backButton,
                            profileImageButton,
                            nameLabel,
                            dividerLine)
        
        bottomView.addSubviews(plusButton,
                               messageTextView,
                               sendButton)
        
        disclaimerView.addSubviews(disclaimerTitleLabel,
                                   disclaimerDescriptionLabel)
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(66.adjustedHeight)
        }
        
        disclaimerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(topView.snp.bottom).offset(28.adjustedHeight)
            $0.height.equalTo(72)
        }
        
        disclaimerTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(5)
        }
        
        disclaimerDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(9)
            $0.bottom.equalToSuperview().inset(12.adjustedHeight)
        }
        
        profileImageButton.snp.makeConstraints {
            $0.size.equalTo(44.adjusted)
            $0.centerY.equalTo(backButton)
            $0.leading.equalTo(backButton.snp.trailing).offset(15)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageButton)
            $0.leading.equalTo(profileImageButton.snp.trailing).offset(18)
        }
        
        dividerLine.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-66.adjustedHeight)
        }
        
        plusButton.snp.makeConstraints {
            $0.size.equalTo(42.adjusted)
            $0.leading.equalToSuperview().inset(8)
            $0.top.equalToSuperview().inset(11)
        }
        
        messageTextView.snp.makeConstraints {
            $0.leading.equalTo(plusButton.snp.trailing).offset(-1.5)
            $0.top.height.equalTo(plusButton)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        sendButton.snp.makeConstraints {
            $0.top.size.equalTo(plusButton)
            $0.trailing.equalTo(messageTextView)
        }
        
        chatRoomCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
    }
}
