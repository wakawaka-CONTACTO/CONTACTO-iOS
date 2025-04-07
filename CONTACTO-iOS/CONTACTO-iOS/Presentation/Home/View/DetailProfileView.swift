//
//  DetailProfileView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import SnapKit
import Then

final class DetailProfileView: BaseView {
    
    let scrollView = UIScrollView()
    private let contentsView = UIView()
    let amplitude = DetailAmplitudeSender()
    
    private let topGradientView = UIImageView()
    lazy var portImageCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: portImageFlowLayout
    )
    let portImageFlowLayout = UICollectionViewFlowLayout()
    
    lazy var pageCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pageFlowLayout
    )
    let pageFlowLayout = UICollectionViewFlowLayout()
    
    let nameLabel = UILabel()
    let nationalityLabel = UILabel()

    lazy var talentCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: talentFlowLayout
    )
    let talentFlowLayout = LeftAlignedCollectionViewFlowLayout()
    
    let descriptionLabel = UILabel()
    let purposeLabel = UILabel()
    
    lazy var purposeCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: purposeFlowLayout
    )
    private let purposeFlowLayout = UICollectionViewFlowLayout()
    
    let instaButton = UIButton()
    let webButton = UIButton()
    
    let bottomGradientView = UIImageView()
    let popButton = UIButton()
    
    let blockButton = UIButton()
    let reportButton = UIButton()
    
    override func setStyle() {
        
        scrollView.do {
            $0.contentInsetAdjustmentBehavior = .never
            $0.showsHorizontalScrollIndicator = false
        }
        
        topGradientView.do {
            $0.image = .imgTopGradient
        }
        
        portImageCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 0
            $0.isPagingEnabled = true
        }
        
        portImageFlowLayout.do {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .horizontal
        }
        
        pageCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 1
            $0.isScrollEnabled = false
        }
        
        pageFlowLayout.do {
            $0.minimumInteritemSpacing = 5.adjustedWidth
            $0.scrollDirection = .horizontal
        }
        
        nameLabel.do {
            $0.font = .fontContacto(.title3)
            $0.textColor = .ctgray6
        }
        
        nationalityLabel.do {
            $0.font = .fontContacto(.title)
            $0.textColor = .ctgray6
        }
        
        talentCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 2
        }
        
        talentFlowLayout.do {
            $0.minimumLineSpacing = 5.adjustedWidth
            $0.minimumInteritemSpacing = 4
            $0.estimatedItemSize = CGSize(width: .bitWidth, height: 19)
        }
        
        descriptionLabel.do {
            $0.textColor = .ctgray6
            $0.font = .fontContacto(.caption5)
            $0.textAlignment = .left
            $0.lineBreakMode = .byCharWrapping
            $0.numberOfLines = 0
        }
        
        purposeLabel.do {
            $0.text = StringLiterals.Home.Profile.purpose
            $0.textColor = .ctgray6
            $0.font = .fontContacto(.caption6)
            $0.numberOfLines = 0
        }
        
        purposeCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 3
        }
        
        purposeFlowLayout.do {
            $0.minimumLineSpacing = 12.adjustedWidth
            $0.minimumInteritemSpacing = 13
        }
        
        instaButton.do {
            $0.setTitle(StringLiterals.Home.Profile.insta, for: .normal)
            $0.setTitleColor(.ctgray7, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.font = .fontContacto(.caption6)
            $0.setUnderline(forText: "instagram")
        }
        
        webButton.do {
            $0.setTitle(StringLiterals.Home.Profile.website, for: .normal)
            $0.setTitleColor(.ctgray7, for: .normal)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.font = .fontContacto(.caption6)
            $0.setUnderline(forText: "website")
        }
        
        bottomGradientView.do {
            $0.image = .imgBottomGradient
            $0.contentMode = .scaleAspectFill
        }
        
        popButton.do {
            $0.setImage(.icExit, for: .normal)
        }
        
        blockButton.do {
            $0.setTitle(StringLiterals.Home.Profile.block, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray8, for: .normal)
        }

        reportButton.do {
            $0.setTitle(StringLiterals.Home.Profile.report, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button1)
            $0.setBackgroundColor(.ctgray8, for: .normal)
        }
    }
    
    override func setLayout() {
        self.addSubviews(scrollView,
                         topGradientView,
                         bottomGradientView,
                         popButton)
        scrollView.addSubviews(contentsView)
        contentsView.addSubviews(portImageCollectionView,
                               pageCollectionView,
                               nameLabel,
                               nationalityLabel,
                               talentCollectionView,
                               descriptionLabel,
                               purposeLabel,
                               purposeCollectionView,
                               instaButton,
                               webButton,
                               blockButton,
                               reportButton)
        
        contentsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        topGradientView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        
        portImageCollectionView.snp.makeConstraints {
            $0.top.width.centerX.equalToSuperview()
            $0.height.equalTo(432)
        }
        
        pageCollectionView.snp.makeConstraints {
            $0.top.equalTo(portImageCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(17.adjustedWidth)
            $0.height.equalTo(3.5)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(13)
            $0.top.equalTo(pageCollectionView.snp.bottom).offset(21)
        }
        
        nationalityLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(13)
            $0.top.equalTo(nameLabel.snp.bottom).offset(21)
        }
        
        talentCollectionView.snp.makeConstraints {
            $0.top.equalTo(nationalityLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(0)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(talentCollectionView.snp.bottom).offset(10)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(13)
        }
        
        purposeLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            $0.leading.equalTo(nameLabel)
        }
        
        purposeCollectionView.snp.makeConstraints {
            $0.top.equalTo(purposeLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(purposeCollectionView.contentSize.height)
        }
        
        instaButton.snp.makeConstraints {
            $0.top.equalTo(purposeCollectionView.snp.bottom).offset(27)
            $0.leading.equalTo(nameLabel)
        }
        
        webButton.snp.makeConstraints {
            $0.top.bottom.equalTo(instaButton)
            $0.leading.equalTo(instaButton.snp.trailing).offset(116.adjustedWidth)
        }
        
        popButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(72)
            $0.leading.equalToSuperview().inset(30)
        }
        
        blockButton.snp.makeConstraints {
            $0.top.equalTo(instaButton.snp.bottom).offset(87.adjustedWidth)
            $0.leading.equalToSuperview().inset(13)
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(20)
        }

        reportButton.snp.makeConstraints {
            $0.top.equalTo(blockButton)
            $0.leading.equalTo(blockButton.snp.trailing).offset(13)
            $0.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(blockButton.snp.height)
            $0.width.equalTo(blockButton)
        }
    }
}
