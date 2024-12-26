//
//  SplashViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/28/24.
//

import UIKit

import SnapKit
import Then

final class SplashViewController: UIViewController {
    
    let logoImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        changeColor()
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.view.do {
            $0.backgroundColor = .ctmainblue
        }
        
        logoImageView.do {
            $0.image = .imgSplash
        }
    }
    
    private func setLayout() {
        self.view.addSubviews(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func changeColor() {
        UIView.animate(withDuration: 2, animations: {
            self.view.backgroundColor = .ctblack
        })
    }
}
