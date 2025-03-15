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
    var selectButtonAction: (() -> Void) = {}
    var deleteButtonAction: (() -> Void) = {}
    
    let greetLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
    let deleteButton = DeleteButton()
    
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
        HapticService.impact(.light).run()
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
    
    func shake() {
        let layer = self.layer

        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true

        let startAngle: Float = (-0.5) * .pi / 180
        let stopAngle = -startAngle
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.15
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * drand48()
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(shakeAnimation, forKey:"shaking")
    }

    func stopShaking() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }
}

class DeleteButton: UIButton {

    // MARK: - Functions
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -17.adjustedWidth, dy: -17.adjustedHeight)
        return expandedBounds.contains(point)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
