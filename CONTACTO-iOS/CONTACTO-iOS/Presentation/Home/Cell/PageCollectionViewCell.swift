//
//  PageCollectionViewCell.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import SnapKit
import Then

final class PageCollectionViewCell: UICollectionViewCell {
    
    private let pageView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        pageView.backgroundColor = .ctgray5
    }
    
    private func setLayout() {
        self.addSubviews(pageView)
        
        pageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func selectedView() {
        pageView.backgroundColor = .ctmainblue
    }
    
    func unselectedView() {
        pageView.backgroundColor = .ctgray5
    }
}
