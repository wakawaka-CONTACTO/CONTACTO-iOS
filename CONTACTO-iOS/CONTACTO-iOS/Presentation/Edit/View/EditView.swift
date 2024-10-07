//
//  EditView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class EditView: BaseView {
    
    private let topView = UIView()
    private let topImageView = UIImageView()
    
    private let scrollView = UIScrollView()
    private let contentsView = UIView()
    private let editLabel = UILabel()
    private let editLineView = UIView()
    let previewButton = UIButton()
    
    lazy var portfolioCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: portfolioFlowLayout
    )
    private let portfolioFlowLayout = UICollectionViewFlowLayout()
    
    let nameTextField = UITextField()
    
    private let talentLabel = UILabel()
    lazy var talentCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: talentFlowLayout
    )
    private let talentFlowLayout = UICollectionViewFlowLayout()
    
    private let descriptionLabel = UILabel()
    let descriptionTextView = UITextView()
    
    private let purposeLabel = UILabel()
    lazy var purposeCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: purposeFlowLayout
    )
    private let purposeFlowLayout = UICollectionViewFlowLayout()
    
    private let snsWebLabel = UILabel()
    private let instaLabel = UILabel()
    let instaTextField = UITextField()
    private let webLabel = UILabel()
    let webTextField = UITextField()
    
    let editButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctgray4
        
        topView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = .imgEditTopLogo
            $0.contentMode = .scaleAspectFit
        }
        
        // style 정의
    }
    
    override func setLayout() {
        addSubviews(topView,
                    scrollView,
                    editButton)
        topView.addSubviews(topImageView)
        scrollView.addSubviews(contentsView)
        contentsView.addSubviews(editLabel,
                                 editLineView,
                                 previewButton,
                                 portfolioCollectionView,
                                 nameTextField,
                                 talentLabel,
                                 talentCollectionView,
                                 descriptionLabel,
                                 descriptionTextView,
                                 purposeLabel,
                                 purposeCollectionView,
                                 snsWebLabel,
                                 instaLabel,
                                 instaTextField,
                                 webLabel,
                                 webTextField)
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(98.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // layout 정의
        
        editButton.snp.makeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
    }
}
