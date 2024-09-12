//
//  OnboardingPurposeButton.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit

final class OnboardingPurposeButton: UIButton {
    var num = 0
    var isTapped = false
    
    let nameArray = [StringLiterals.Onboarding.Purpose.getalong,
                     StringLiterals.Onboarding.Purpose.collaborate,
                     StringLiterals.Onboarding.Purpose.makenew,
                     StringLiterals.Onboarding.Purpose.art,
                     StringLiterals.Onboarding.Purpose.group]
    
    let colorArray: [UIColor] = [.ctsubred,
                                 .ctsubpink,
                                 .ctsubblue2,
                                 .ctsubyellow2,
                                 .ctsubgreen1]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(num: Int) {
        super.init(frame: .zero)
        self.num = num
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
        self.setBackgroundColor(.ctwhite, for: .normal)
        self.setBackgroundColor(.ctwhite, for: .highlighted)
        self.setTitle(nameArray[num], for: .normal)
        self.setTitleColor(.ctblack, for: .normal)
        self.titleLabel?.font = .fontContacto(.button1)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth - 32.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
    }
    
    func buttonTapped() {
        isTapped.toggle()
        
        if isTapped {
            setBackgroundColor(colorArray[num], for: .normal)
            setBackgroundColor(colorArray[num], for: .highlighted)
        } else {
            setBackgroundColor(.ctwhite, for: .normal)
            setBackgroundColor(.ctwhite, for: .highlighted)
        }
    }
}
