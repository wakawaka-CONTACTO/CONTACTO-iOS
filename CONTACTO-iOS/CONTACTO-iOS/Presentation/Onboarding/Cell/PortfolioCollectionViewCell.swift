//
//  PortfolioCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class PortfolioCollectionViewCell: UICollectionViewCell {
    
    var isFilled = false {
        didSet {
            updateState()
        }
    }
    
    let backgroundButton = UIButton()
    let backgroundImageView = UIImageView()
    let cancelButton = UIButton()
    private let uploadStackView = UIStackView()
    private let uploadImageView = UIImageView()
    private let uploadLabel = UILabel()
    
    var uploadAction: (() -> Void) = {}
    var cancelAction: (() -> Void) = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        updateState()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        backgroundButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        uploadAction = {}
        cancelAction = {}
        isFilled = false
    }
    
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        backgroundButton.do {
            $0.backgroundColor = .ctgray3
        }
        
        backgroundImageView.do {
            $0.isHidden = true
            $0.isUserInteractionEnabled = true
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        cancelButton.do {
            $0.isHidden = true
            $0.setImage(.icCancel, for: .normal)
        }
        
        uploadStackView.do {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 5.5
            $0.isUserInteractionEnabled = false
        }
        
        uploadImageView.do {
            $0.image = .icUpload
        }
        
        uploadLabel.do {
            $0.text = StringLiterals.Onboarding.Portfolio.upload
            $0.font = .fontContacto(.caption4)
            $0.textColor = .ctblack
        }
    }
    
    private func setLayout() {
        self.addSubviews(backgroundButton,
                         backgroundImageView)
        backgroundButton.addSubviews(uploadStackView)
        backgroundImageView.addSubviews(cancelButton)
        uploadStackView.addArrangedSubviews(uploadImageView,
                                            uploadLabel)
        
        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(402)
            $0.width.equalTo(306)
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(402)
            $0.width.equalTo(306)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(-1)
        }
        
        uploadStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func updateState() {
        backgroundButton.isHidden = isFilled
        backgroundImageView.isHidden = !isFilled
        cancelButton.isHidden = !isFilled
    }
    
    @objc func uploadButtonTapped() {
        uploadAction()
    }
    
    @objc func cancelButtonTapped() {
        cancelAction()
        isFilled = false
    }
}
