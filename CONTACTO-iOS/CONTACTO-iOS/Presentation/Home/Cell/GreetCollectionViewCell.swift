//
//  GreetCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class GreetCollectionViewCell: UICollectionViewCell {
    
    var num = 0
    var deleteNum = 0
    var selectButtonAction: (() -> Void) = {}
    var deleteButtonAction: (() -> Void) = {}
    
    let greetLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
    let deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        greetLabel.text = ""
        selectButtonAction = {}
        deleteButtonAction = {}
    }
    
    private func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        greetLabel.addGestureRecognizer(tapGesture)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func tapLabel() {
        selectButtonAction()
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonAction()
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.clipsToBounds = false
        
        greetLabel.do {
            $0.backgroundColor = .ctmainblue
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button7)
            $0.isUserInteractionEnabled = true
        }
        
        deleteButton.do {
            $0.setImage(.icDeleteGreet, for: .normal)
            $0.isHidden = true
            $0.contentMode = .scaleAspectFill
        }
    }
    
    private func setLayout() {
        self.addSubviews(greetLabel,
                         deleteButton)
        
        greetLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.size.equalTo(25.adjusted)
            $0.centerX.equalTo(greetLabel.snp.trailing)
            $0.centerY.equalTo(greetLabel.snp.top)
        }
    }
}
