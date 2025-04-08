//
//  ProfilePurposeCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ProfilePurposeCollectionViewCell: UICollectionViewCell, EditAmplitudeSender {
    var tapAction: (() -> Void) = {}
    
    var num = 0
    var isTapped = false {
        didSet {
            self.backgroundColor = isTapped ? colorArray[num] : (isEditing ? .ctwhite : .clear)
        }
    }
    var isEditing = false {
        didSet {
            self.backgroundColor = isTapped ? colorArray[num] : (isEditing ? .ctwhite : .clear)
        }
    }
    
    private let purposeList = [
        StringLiterals.Onboarding.Purpose.getalong,
        StringLiterals.Onboarding.Purpose.collaborate,
        StringLiterals.Onboarding.Purpose.makenew,
        StringLiterals.Onboarding.Purpose.art,
        StringLiterals.Onboarding.Purpose.group
    ]
    
    private let colorArray: [UIColor] = [.ctsubred,
                                 .ctsubpink,
                                 .ctsubblue2,
                                 .ctsubyellow2,
                                 .ctsubgreen1]
    
    let purposeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tapAction = {}
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.do {
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.2, cornerRadius: 0)
        }
        
        purposeLabel.do {
            $0.textColor = .ctblack
            $0.font = .fontContacto(.button6)
        }
    }
    
    private func setLayout() {
        self.addSubviews(purposeLabel)
        
        purposeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(4)
        }
    }
    
    func config(num: Int) {
        self.num = num
        self.backgroundColor = isTapped ? colorArray[num] : (isEditing ? .ctwhite : .clear)
        purposeLabel.text = purposeList[num]
    }
    
    /// Edit 화면에서 필요한 Target
    func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(purposeLabelTapped))
        self.purposeLabel.isUserInteractionEnabled = true
        self.purposeLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func purposeLabelTapped() {
        if isEditing {
            isTapped.toggle()
            tapAction()
            self.sendAmpliLog(eventName: EventName.CLICK_EDIT_PURPOSE)
        }
    }
}
