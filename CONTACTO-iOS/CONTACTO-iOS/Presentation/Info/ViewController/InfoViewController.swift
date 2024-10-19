//
//  InfoViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/20/24.
//

import UIKit

import SnapKit
import Then

final class InfoViewController: BaseViewController {
    private let infoView = InfoView()
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(infoView)
        
        infoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
}
