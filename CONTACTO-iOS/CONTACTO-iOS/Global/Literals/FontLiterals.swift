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
}

enum FontLevel {
    case title1
    
    case body1
    
    case caption1
    case caption2
    case caption3
    
    case button1
    case button2
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .title1:
            return FontName.ABCDiatypeBold.rawValue
        case .body1:
            return FontName.ABCDiatypeBold.rawValue
        case .caption1:
            return FontName.ABCDiatypeMedium.rawValue
        case .caption2:
            return FontName.ABCDiatypeBold.rawValue
        case .caption3:
            return FontName.ABCDiatypeBoldItalic.rawValue
        case .button1:
            return FontName.FKRasterRomanBlended.rawValue
        case .button2:
            return FontName.ABCDiatypeBold.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title1:
            return 35.adjusted
        case .body1:
            return 14.adjusted
        case .caption1:
            return 20.adjusted
        case .caption2:
            return 10.adjusted
        case .caption3:
            return 7.adjusted
        case .button1:
            return 16.adjusted
        case .button2:
            return 16.adjusted
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .title1:
            return FontLevel.title1.fontSize * 1.13
        case .body1:
            return FontLevel.body1.fontSize
        case .caption1:
            return FontLevel.caption1.fontSize * 1.5
        case .caption2:
            return FontLevel.caption1.fontSize * 1.13
        case .caption3:
            return FontLevel.caption3.fontSize * 1.5
        case .button1:
            return FontLevel.button1.fontSize * 1.5
        case .button2:
            return FontLevel.button2.fontSize * 1.5
        }
    }
}
