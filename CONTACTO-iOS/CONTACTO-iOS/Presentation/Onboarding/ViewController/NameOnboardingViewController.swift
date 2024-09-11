//
//  NameOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then

final class NameOnboardingViewController: BaseViewController {
    
    private let nameOnboardingView = NameOnboardingView()

    // MARK: Navigation Function
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setLayout() {
        view.addSubviews(nameOnboardingView)
        
        nameOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NameOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
