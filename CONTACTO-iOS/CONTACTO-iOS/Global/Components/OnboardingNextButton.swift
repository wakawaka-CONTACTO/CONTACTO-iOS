//
//  OnboardingNextButton.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit

final class OnboardingNextButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(count: Int) {
        super.init(frame: .zero)
        setStyle()
        setLayout()
        self.setTitle("\(count) / 6", for: .normal)
    }
    
    // MARK: - UI
    private func setStyle() {
        self.isEnabled = false
        self.setTitle(StringLiterals.Onboarding.Name.button, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = .fontContacto(.button)
        self.setBackgroundColor(UIColor(hex: "C8C8C8"), for: .disabled)
        self.setBackgroundColor(UIColor(hex: "17DB4E"), for: .normal)
        self.setRoundBorder(borderColor: .black, borderWidth: 1.5, cornerRadius: 0)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth - 32.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
    }
}
