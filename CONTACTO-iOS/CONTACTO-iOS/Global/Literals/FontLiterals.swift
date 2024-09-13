//
//  FontLiterals.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

enum FontName: String {
    case ABCDiatypeMedium = "ABCDiatypeUnlicensedTrial-Medium"
    case ABCDiatypeBold = "ABCDiatypeUnlicensedTrial-Bold"
    case ABCDiatypeBoldItalic = "ABCDiatypeUnlicensedTrial-BoldItalic"
    case FKRasterRomanRounded = "FKRasterRomanCompactTrial-Rounded"
    case FKRasterRomanBlended = "FKRasterRomanCompactTrial-Blended"
    case FKRasterRomanSharp = "FKRasterRomanCompactTrial-Sharp"
    case FKRasterRomanSmooth = "FKRasterRomanCompactTrial-Smooth"
    case PretendardRegular = "Pretendard-Regular"
}

enum FontLevel {
    case title1
    case title2
    
    case body1
    case body2
    
    case caption1
    case caption2
    case caption3
    case caption4
    case caption5
    
    case button1
    case button2
    case button3
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .title1, .title2, .body1, .body2, .caption2, .button2:
            return FontName.ABCDiatypeBold.rawValue
        case .caption1, .button3:
            return FontName.ABCDiatypeMedium.rawValue
        case .caption3:
            return FontName.ABCDiatypeBoldItalic.rawValue
        case .button1:
            return FontName.FKRasterRomanBlended.rawValue
        case .caption4, .caption5:
            return FontName.PretendardRegular.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title1:
            return 35.adjusted
        case .title2:
            return 39.adjusted
        case .body1, .caption4:
            return 14.adjusted
        case .body2:
            return 12.adjusted
        case .caption1:
            return 20.adjusted
        case .caption2:
            return 10.adjusted
        case .caption3:
            return 7.adjusted
        case .button1, .button2, .caption5:
            return 16.adjusted
        case .button3:
            return 11.adjusted
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .title1, .title2, .caption2:
            return FontLevel.title1.fontSize * 1.13
        case .body1, .body2:
            return FontLevel.body2.fontSize
        case .caption1, .caption3, .caption4, .caption5, .button1, .button2:
            return FontLevel.caption1.fontSize * 1.5
        case .button3:
            return FontLevel.button3.fontSize * 1.3
        }
    }
}
