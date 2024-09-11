//
//  UIFont+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

extension UIFont {
    static func fontContacto(_ fontLevel: FontLevel) -> UIFont {
        guard let font = UIFont(name: fontLevel.fontWeight, size: fontLevel.fontSize) else {
            return .systemFont(ofSize: fontLevel.fontSize)
        }
        
        return font
    }
}
