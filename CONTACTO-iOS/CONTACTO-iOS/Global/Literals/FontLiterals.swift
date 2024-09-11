//
//  FontLiterals.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

// TODO: 추후 다시 나오면 수정
enum FontName: String {
    case pretendard
}

enum FontLevel {
    case body
}

extension FontLevel {
    
    var fontWeight: String {
        switch self {
        case .body:
            return FontName.pretendard.rawValue
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .body:
            return 10
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case.body:
            return 10
        }
    }
}
