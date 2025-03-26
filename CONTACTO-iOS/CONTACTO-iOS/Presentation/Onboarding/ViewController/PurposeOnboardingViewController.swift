//
//  PurposeOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class PurposeOnboardingViewController: BaseViewController, OnboadingAmplitudeSender {
    
    private let purposeOnboardingView = PurposeOnboardingView()
    
    // MARK: Navigation Function
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setLayout() {
        view.addSubviews(purposeOnboardingView)
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING2)
        
        purposeOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        purposeOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc private func nextButtonTapped() {
        var purpose_count =  purposeOnboardingView.selectedPurpose.count
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING2_NEXT, properties: ["purpose_count": purpose_count])
        UserInfo.shared.userPurposes = purposeOnboardingView.selectedPurpose
        let explainOnboardingViewController = ExplainOnboardingViewController()
        self.navigationController?.pushViewController(explainOnboardingViewController, animated: true)
    }
}

extension PurposeOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
