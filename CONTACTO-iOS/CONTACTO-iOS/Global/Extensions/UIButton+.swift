//
//  UIButton+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

extension UIButton {
    
    /// Button 모서리 커스텀 - 색상, 모서리 두께, 둥근 정도
    func makeRoundBorder(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let minimumSize: CGSize = CGSize(width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(minimumSize)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: minimumSize))
        }
        
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.clipsToBounds = true
        self.setBackgroundImage(colorImage, for: state)
    }
    
    func setUnderline(forText text: String) {
        guard let title = title(for: .normal) else { return }
        
        let attributedString = NSMutableAttributedString(string: title)
        
        let fullRange = NSRange(location: 0, length: title.count)
        let textRange = (title as NSString).range(of: text)
        
        if textRange.location != NSNotFound {
            attributedString.addAttribute(.underlineStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: textRange)
        }
        
        setAttributedTitle(attributedString, for: .normal)
    }
}
