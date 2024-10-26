//
//  ChatListView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class ChatListView: BaseView {
    lazy var chatListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: chatFlowLayout
    )
    let chatFlowLayout = UICollectionViewFlowLayout()
    
    private let gradientView = UIImageView()
    
    override func setStyle() {
        self.backgroundColor = .ctmainpink
        
        chatListCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 51.adjustedHeight, right: 0)
        }
        
        chatFlowLayout.do {
            $0.minimumLineSpacing = 0
            $0.estimatedItemSize = CGSize(width: SizeLiterals.Screen.screenWidth, height: 97)
            $0.scrollDirection = .vertical
        }
        
        gradientView.do {
            $0.image = .imgPinkGradient
            $0.contentMode = .scaleAspectFill
            $0.alpha = 0.8
        }
    }
    
    override func setLayout() {
        addSubviews(chatListCollectionView,
                    gradientView)
        
        chatListCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
