//
//  UIView+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

extension UIView {
    
    /// 한 번에 여러 개의 UIView 또는 UIView의 하위 클래스 객체들을 상위 UIView에 추가
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    /// UIView 의 모서리 커스텀 - 색상, 모서리 두께, 둥근 정도
    func setRoundBorder(borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        layer.masksToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    func showToast(message: String, position: ToastPosition = .top) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor(hex: "343A40", alpha: 0.5)
        toastLabel.textColor = .ctgray1
        toastLabel.textAlignment = .center
        toastLabel.font = .fontContacto(.gothicButton)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 0
        toastLabel.clipsToBounds = true
        
        let toastWidth = 253.adjusted
        let toastHeight = 40.adjusted
        
        var yPosition: CGFloat
        switch position {
        case .top:
            yPosition = 50.adjusted
        case .middle:
            yPosition = self.frame.size.height / 2 - toastHeight / 2
        }
        
        toastLabel.frame = CGRect(x: self.frame.size.width / 2 - toastWidth / 2,
                                  y: yPosition,
                                  width: toastWidth,
                                  height: toastHeight)
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(toastLabel)
        }
        
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    enum ToastPosition {
        case top
        case middle
    }
}
