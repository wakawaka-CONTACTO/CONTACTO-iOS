//
//  HomeViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/13/24.
//

import UIKit

import SnapKit
import Then

final class HomeViewController: BaseViewController {
    let homeView = HomeView()
    
    override func setLayout() {
        view.addSubviews(homeView)
        
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
