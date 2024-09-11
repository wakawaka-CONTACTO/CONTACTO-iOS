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
    
    case caption1
    case caption2
    
    case button
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .title1:
            return FontName.ABCDiatypeBold.rawValue
        case .caption1:
            return FontName.ABCDiatypeMedium.rawValue
        case .caption2:
            return FontName.ABCDiatypeBold.rawValue
        case .button:
            return FontName.FKRasterRomanBlended.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .title1:
            return 35.adjusted
        case .caption1:
            return 20.adjusted
        case .caption2:
            return 10.adjusted
        case .button:
            return 16.adjusted
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .title1:
            return FontLevel.title1.fontSize * 1.13
        case .caption1:
            return FontLevel.caption1.fontSize * 1.5
        case .caption2:
            return FontLevel.caption1.fontSize * 1.13
        case .button:
            return FontLevel.button.fontSize * 1.5
        }
    }
}
