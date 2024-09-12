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
        self.setTitleColor(.ctblack, for: .normal)
        self.titleLabel?.font = .fontContacto(.button)
        self.setBackgroundColor(.ctgray3, for: .disabled)
        self.setBackgroundColor(.ctsubgreen2, for: .normal)
        self.setBackgroundColor(.ctsubgreen2, for: .highlighted)
        self.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(SizeLiterals.Screen.screenWidth - 32.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
    }
}
