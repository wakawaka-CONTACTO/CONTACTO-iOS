//
//  UIImage+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

extension UIImage {
    func isEqualTo(_ image: UIImage) -> Bool {
        guard let data1 = self.pngData(), let data2 = image.pngData() else {
            return false
        }
        return data1 == data2
    }
}

