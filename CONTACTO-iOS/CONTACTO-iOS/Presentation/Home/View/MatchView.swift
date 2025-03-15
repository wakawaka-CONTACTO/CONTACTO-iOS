//
//  MatchView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class MatchView: BaseView {
    
    let titleLabel = UILabel()
    let myImageView = UIImageView()
    let myLabel = BasePaddingLabel()
    
    let yourImageView = UIImageView()
    let yourLabel = BasePaddingLabel()
    
    let descriptionLabel = UILabel()
    
    lazy var greetCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: greetFlowLayout
    )
    let greetFlowLayout = LeftAlignedCollectionViewFlowLayout()
    
    let fieldView = UIView()
    let sendButton = UIButton()
    
    lazy var textCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: textImageFlowLayout
    )
    let textImageFlowLayout = LeftAlignedCollectionViewFlowLayout()
    
    let popButton = UIButton()
    
    override func setStyle() {
        titleLabel.do {
            $0.text = StringLiterals.Home.Match.title
            $0.textColor = .ctwhite
            $0.font = .fontContacto(.title4)
        }
        
        myImageView.do {
            $0.image = .imgex3
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        myLabel.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1, cornerRadius: 0)
            $0.backgroundColor = .ctmainpink
            $0.text = "Instant Wise"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button6)
        }
        
        yourImageView.do {
            $0.image = .imgex2
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        yourLabel.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1, cornerRadius: 0)
            $0.backgroundColor = .ctmainblue
            $0.text = "Pacay Pacay"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button6)
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Home.Match.description
            $0.textColor = .ctwhite
            $0.font = .fontContacto(.title5)
        }
        
        greetCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isHidden = true
            $0.tag = 0
        }
        
        greetFlowLayout.do {
            $0.minimumLineSpacing = 13.adjustedWidth
            $0.estimatedItemSize = CGSize(width: .bitWidth, height: 28)
        }
        
        fieldView.do {
            $0.backgroundColor = .ctgray8
        }
        
        sendButton.do {
            $0.setBackgroundColor(.ctmainblue, for: .normal)
            $0.setImage(.icPolygon, for: .normal)
        }
        
        textCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.isHidden = true
            $0.tag = 1
            $0.contentInset = UIEdgeInsets(top: 5.adjustedWidth, left: 0, bottom: 0, right: 5.adjustedWidth)
        }
        
        textImageFlowLayout.do {
            $0.minimumLineSpacing = 10.adjustedWidth
            $0.estimatedItemSize = CGSize(width: .bitWidth, height: 32)
            $0.scrollDirection = .horizontal
        }
        
        popButton.do {
            $0.setImage(.icExit, for: .normal)
        }
    }
    
    override func setLayout() {
        self.addSubviews(titleLabel,
                         myImageView,
                         myLabel,
                         yourImageView,
                         yourLabel,
                         descriptionLabel,
                         greetCollectionView,
                         fieldView,
                         sendButton,
                         popButton)
        
        fieldView.addSubviews(textCollectionView)
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(170.adjustedHeight)
        }
        
        myImageView.snp.makeConstraints {
            $0.size.equalTo(SizeLiterals.Screen.screenWidth / 2)
            $0.top.equalTo(titleLabel.snp.bottom).offset(23.adjustedHeight)
            $0.leading.equalToSuperview()
        }
        
        myLabel.snp.makeConstraints {
            $0.center.equalTo(myImageView)
        }
        
        yourImageView.snp.makeConstraints {
            $0.size.equalTo(SizeLiterals.Screen.screenWidth / 2)
            $0.top.equalTo(titleLabel.snp.bottom).offset(23.adjustedHeight)
            $0.trailing.equalToSuperview()
        }
        
        yourLabel.snp.makeConstraints {
            $0.center.equalTo(yourImageView)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(myImageView.snp.bottom).offset(70.adjustedHeight)
        }
        
        greetCollectionView.snp.makeConstraints {
            $0.top.equalTo(myImageView.snp.bottom).offset(72.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(28.adjustedHeight)
        }
        
        fieldView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(17.adjustedHeight)
            $0.leading.equalToSuperview().inset(8)
            $0.height.equalTo(42.adjustedHeight)
        }
        
        textCollectionView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(5.adjusted)
            $0.top.bottom.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints {
            $0.size.equalTo(42.adjusted)
            $0.top.equalTo(fieldView)
            $0.leading.equalTo(fieldView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().inset(8)
        }
        
        popButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(72)
            $0.leading.equalToSuperview().inset(30)
        }
    }
}
