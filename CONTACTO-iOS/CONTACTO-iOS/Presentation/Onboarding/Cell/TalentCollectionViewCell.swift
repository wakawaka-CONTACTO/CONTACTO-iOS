//
//  TalentCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class TalentCollectionViewCell: UICollectionViewCell {
    
    var isTapped = false
    var talent = TalentInfo(koreanName: "", displayName: "", category: .ART_CRAFT) {
        didSet {
            self.talentButton.setTitle(talent.displayName, for: .normal)
        }
    }
    private let colorArray: [UIColor] = [.ctsubpink, .ctsubblue1, .ctsubbrown]
    
    var updateButtonAction: (() -> Void) = {}
    
    let talentButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        talentButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        talentButton.setTitle("", for: .normal)
        updateButtonAction = {}
        isTapped = false
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    func setStyle() {
        talentButton.do {
            $0.setBackgroundColor(.ctwhite, for: .normal)
            $0.setBackgroundColor(.ctwhite, for: .highlighted)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 0.85, cornerRadius: 0)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.textAlignment = .center
            $0.titleLabel?.font = .fontContacto(.button3)
        }
    }
    
    func setLayout() {
        self.addSubviews(talentButton)
        
        talentButton.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.equalTo((SizeLiterals.Screen.screenWidth - 73.adjustedWidth) / 3)
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func buttonTapped() {
        isTapped.toggle()
        updateButtonAppearance()
        updateButtonAction()
    }
    
    func setTalent(_ talent: TalentInfo, isSelectedFromEditTalent: Bool) {
        self.talent = talent
        self.isTapped = isSelectedFromEditTalent
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        if isTapped {
            talentButton.setBackgroundColor(talent.category.color, for: .normal)
            talentButton.setBackgroundColor(talent.category.color, for: .highlighted)
        } else {
            talentButton.setBackgroundColor(.ctwhite, for: .normal)
            talentButton.setBackgroundColor(.ctwhite, for: .highlighted)
        }
    }
}
