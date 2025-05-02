//
//  UILabel+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

extension UILabel {
    
    /// font 변경
    func asFont(targetString: String, font: UIFont) {
        let originText = text ?? ""
        let attributedString = NSMutableAttributedString(string: originText)
        let range = (originText as NSString).range(of: targetString, options: .caseInsensitive)
        attributedString.addAttribute(.font, value: font, range: range)
        attributedText = attributedString
    }
    
    /// color 변경
    func asColor(targetString: String, color: UIColor) {
        let originText = text ?? ""
        let attributedString = NSMutableAttributedString(string: originText)
        let range = (originText as NSString).range(of: targetString)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        attributedText = attributedString
    }
    
    /// font, color 둘 다 변경
    func asFontColor(targetString: String, font: UIFont, color: UIColor) {
        let originText = text ?? ""
        let attributedString = NSMutableAttributedString(string: originText)
        let range = (originText as NSString).range(of: targetString)
        attributedString.addAttributes([.font: font as Any, .foregroundColor: color as Any], range: range)
        attributedText = attributedString
    }
    
    func asLineHeight(_ fontStyle: FontLevel) {
        
        let lineHeight = fontStyle.lineHeight
        
        if let text = text {
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: style,
                .baselineOffset: (lineHeight - font.lineHeight) / 4
            ]
            
            let attrString = NSAttributedString(string: text,
                                                attributes: attributes)
            self.attributedText = attrString
        }
    }
    
    /// 자간
    func addCharacterSpacing(_ value: Double) {
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}

/// UILabel을 상속한 커스텀 클래스로, 줄 높이가 있는 텍스트의 클리핑 문제를 해결
class LineHeightLabel: UILabel {
    
    // 텍스트 렌더링 영역에 상하좌우 여백 추가
    override func drawText(in rect: CGRect) {
        // 상단과 하단에 추가 여백
        let insets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        super.drawText(in: rect.inset(by: insets))
    }
    
    // intrinsicContentSize를 오버라이드하여 추가 여백 반영
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: size.height + 8) // 상하 여백(4+4) 추가
    }
    
    // 줄 높이를 지정하는 편의 메서드 
    func setLineHeight(_ fontStyle: FontLevel) {
        self.asLineHeight(fontStyle)
    }
}
