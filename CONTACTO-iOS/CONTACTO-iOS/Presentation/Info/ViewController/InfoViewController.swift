//
//  InfoViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/20/24.
//

import UIKit

import SafariServices
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
    
    override func setAddTarget() {
        infoView.helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        infoView.guidelinesButton.addTarget(self, action: #selector(guidelinesTapped), for: .touchUpInside)
        infoView.cookieButton.addTarget(self, action: #selector(cookieButtonTapped), for: .touchUpInside)
    }
}

extension InfoViewController {
    @objc private func helpButtonTapped() {
        guard let url = URL(string: "https://naver.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func guidelinesTapped() {
        guard let url = URL(string: "https://naver.com") else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc private func cookieButtonTapped() {
        guard let url = URL(string: "https://naver.com") else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
