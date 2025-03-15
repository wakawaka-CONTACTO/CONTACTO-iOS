//
//  FontLiterals.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

enum FontName: String {
    case ABCDiatypeRegular = "ABCDiatypeUnlicensedTrial-Regular"
    case ABCDiatypeMedium = "ABCDiatypeUnlicensedTrial-Medium"
    case ABCDiatypeBold = "ABCDiatypeUnlicensedTrial-Bold"
    case ABCDiatypeBoldItalic = "ABCDiatypeUnlicensedTrial-BoldItalic"
    case FKRasterRomanRounded = "FKRasterRomanCompactTrial-Rounded"
    case FKRasterRomanBlended = "FKRasterRomanCompactTrial-Blended"
    case FKRasterRomanSharp = "FKRasterRomanCompactTrial-Sharp"
    case FKRasterRomanSmooth = "FKRasterRomanCompactTrial-Smooth"
    case PretendardRegular = "Pretendard-Regular"
    case PretendardBold = "Pretendard-Bold"
}

enum FontLevel {
    case title1
    case title2
    case title3
    case title4
    case title5
    case title6
    
    case body1
    case body2
    case body3
    
    case caption1
    case caption2
    case caption3
    case caption4
    case caption5
    case caption6
    case caption7
    case caption8
    case caption9
    case caption10
    
    case button1
    case button2
    case button3
    case button4
    case button5
    case button6
    case button7
    case button8
    
    case button
    case title
    case subTitle
    case chat
    case body
    case gothicButton
    case gothicSubButton
    case number
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .title1, .title2, .body1, .body2, .body3, .caption2, .button2, .button3, .button8:
            return FontName.ABCDiatypeBold.rawValue
        case .caption1, .button5:
            return FontName.ABCDiatypeMedium.rawValue
        case .caption3:
            return FontName.ABCDiatypeBoldItalic.rawValue
        case .caption6, .caption7, .caption9:
            return FontName.ABCDiatypeRegular.rawValue
        case .button1, .button4, .title3, .button6, .title4, .title5, .button7, .title6:
            return FontName.FKRasterRomanBlended.rawValue
        case .caption4, .caption5, .caption8, .caption10:
            return FontName.PretendardRegular.rawValue
            
        case .button, .subTitle, .body, .gothicButton, .gothicSubButton:
            return FontName.ABCDiatypeBold.rawValue
            
        case .title:
            return FontName.FKRasterRomanBlended.rawValue
            
        case .chat:
            return FontName.PretendardRegular.rawValue
            
        case .number:
            return FontName.PretendardBold.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title1:
            return 35.adjusted
        case .title2:
            return 39.adjusted
        case .body1, .caption4, .button3:
            return 14.adjusted
        case .body2:
            return 12.adjusted
        case .caption1:
            return 20.adjusted
        case .caption2, .caption9:
            return 10.adjusted
        case .caption3, .caption10:
            return 7.adjusted
        case .button1, .button2, .caption5, .caption6, .button7:
            return 16.adjusted
        case .button5:
            return 11.adjusted
        case .button4, .caption7, .body3, .button8:
            return 17.adjusted
        case .title3:
            return 30.adjusted
        case .button6, .caption8:
            return 13.adjusted
        case .title4:
            return 25.adjusted
        case .title5:
            return 23.adjusted
        case .title6:
            return 100.adjusted
            
        case .button, .gothicButton:
            return 16.adjusted
        case .title, .body:
            return 20.adjusted
        case .subTitle:
            return 13.adjusted
        case .chat:
            return 15.adjusted
        case .gothicSubButton:
            return 10.adjusted
        case .number:
            return 17.adjusted
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .title1, .title2, .caption2:
            return FontLevel.title1.fontSize * 1.13
        case .body1, .body2:
            return FontLevel.body2.fontSize
        case .caption1, .caption3, .caption4, .caption5, .button1, .button2, .button4, .caption6, .button6, .title4, .title5, .button8, .caption10:
            return FontLevel.caption1.fontSize * 1.5
        case .button3, .button5, .button7, .caption7, .caption8, .body3:
            return FontLevel.button3.fontSize * 1.3
        case .title3, .caption9:
            return FontLevel.title3.fontSize
        case .title6:
            return FontLevel.title6.fontSize
            
            
        case .button:
            return FontLevel.button.fontSize * 1.5
        case .title:
            return FontLevel.title.fontSize * 1.35
        case .chat:
            return FontLevel.chat.fontSize * 1.35
        case .subTitle:
            return FontLevel.subTitle.fontSize * 1.3
        case .body:
            return FontLevel.body.fontSize * 1.3
        case .gothicButton:
            return FontLevel.gothicButton.fontSize * 1.5
        case .gothicSubButton:
            return FontLevel.gothicSubButton.fontSize * 1.5
        case .number:
            return FontLevel.number.fontSize * 1.3
        }
    }
}
