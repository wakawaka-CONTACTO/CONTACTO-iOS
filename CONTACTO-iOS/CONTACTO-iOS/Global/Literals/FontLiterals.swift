//
//  FontLiterals.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

// TODO: 추후 다시 나오면 수정
enum FontName: String {
    case Diatype = "ABCDiatypeUnlicensedTrial-Medium"
    case FKRasterRoman = "FKRasterRomanCompactTrial-Rounded"
}

enum FontLevel {
    case caption
    case button
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .caption:
            return FontName.Diatype.rawValue
        case .button:
            return FontName.FKRasterRoman.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .caption:
            return 20.adjusted
        case .button:
            return 16.adjusted
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .caption:
            return FontLevel.caption.fontSize * 1.5
        case .button:
            return FontLevel.button.fontSize * 1.5
        }
    }
}
