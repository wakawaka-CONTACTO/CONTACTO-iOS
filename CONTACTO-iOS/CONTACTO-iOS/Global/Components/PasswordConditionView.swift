//
//  PasswordConditionView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/30/24.
//

import UIKit

import SnapKit
import Then

@frozen enum conditionState {
    case letter
    case special
    case num
    case alphabet
}

final class PasswordConditionView: UIView {
    
    var state = conditionState.letter
    var isSatisfied = false {
        didSet {
            checkImageView.image = isSatisfied ? .icConditionCheck : .icConditionCheckX
        }
    }
    
    let checkImageView = UIImageView()
    let conditionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(state: conditionState) {
        super.init(frame: CGRect())
        setUI()
        setViewState(state: state)
    }
}

extension PasswordConditionView {
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        checkImageView.do {
            $0.image = .icConditionCheckX
        }
        
        conditionLabel.do {
            $0.textColor = .ctwhite
            $0.font = .fontContacto(.gothicSubButton)
        }
    }
    
    private func setLayout() {
        self.addSubviews(checkImageView,
                         conditionLabel)
        
        self.snp.makeConstraints {
            $0.height.equalTo(15)
        }
        
        checkImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        
        conditionLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImageView.snp.trailing).offset(4)
            $0.centerY.equalTo(checkImageView)
        }
    }
    
    func setViewState(state: conditionState) {
        self.state = state
        switch state {
        case .letter:
            conditionLabel.text = StringLiterals.Login.condition1
        case .special:
            conditionLabel.text = StringLiterals.Login.condition2
        case .num:
            conditionLabel.text = StringLiterals.Login.condition3
        case .alphabet:
            conditionLabel.text = StringLiterals.Login.condition4
        }
    }
}
