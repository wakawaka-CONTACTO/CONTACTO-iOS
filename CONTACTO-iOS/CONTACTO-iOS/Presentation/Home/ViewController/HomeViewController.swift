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
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        setSwipeAction()
    }
    
    override func setLayout() {
        
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(homeView)
        
        homeView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    private func setSwipeAction() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        
        homeView.portImageView.addGestureRecognizer(leftSwipeGestureRecognizer)
        homeView.portImageView.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
}

extension HomeViewController {
    @objc private func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case .left:
            print("left")
        case .right:
            print("right")
        default:
            print("기타")
        }
    }
}
