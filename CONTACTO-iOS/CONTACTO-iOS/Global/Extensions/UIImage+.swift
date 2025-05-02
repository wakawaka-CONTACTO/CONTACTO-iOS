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
    
    func resized(to targetSize: CGSize) -> UIImage? {
        // 원본 이미지의 비율 계산
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        // 새로운 크기 계산 (원본 비율 유지)
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        #if DEBUG
        print(">>>>>>> image resize >>>>>>>")
        #endif
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func needsResizing(targetSize: CGSize) -> Bool {
        return size.width > targetSize.width || size.height > targetSize.height
    }
}

