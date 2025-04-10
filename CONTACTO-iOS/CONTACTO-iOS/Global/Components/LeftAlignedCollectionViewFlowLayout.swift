//
//  LeftAlignedCollectionViewFlowLayout.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) ->  [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        // 가로 스크롤인 경우는 기본 레이아웃 그대로 사용
        if scrollDirection == .horizontal {
            return attributes
        }
        
        // 세로 스크롤일 때만 왼쪽 정렬 적용
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementKind == nil {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY , maxY)
            }
        }
        return attributes
    }
}
