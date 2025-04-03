//
//  SNSOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit

final class SNSOnboardingViewController: BaseViewController, OnboadingAmplitudeSender {
    
    private let snsOnboardingView = SNSOnboardingView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING4)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setLayout() {
        view.addSubviews(snsOnboardingView)
        
        snsOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        snsOnboardingView.instaTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        snsOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
}

extension SNSOnboardingViewController {
    
    /// 노티피케이션 추가
    func addKeyboardNotifications(){
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification){
        
        self.snsOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(317.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        self.snsOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(55.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if let textField = sender as? UITextField {
            let hasText = !(textField.text?.isEmpty ?? true) && !(textField.text?.isOnlyWhitespace() ?? true)
            let isNationalitySelected = snsOnboardingView.selectedNationality != .NONE
            
            snsOnboardingView.nextButton.isEnabled = hasText && isNationalitySelected
        }
    }

    
    @objc private func nextButtonTapped() {
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING4_NEXT)
        if !validateWebsite(self.snsOnboardingView.websiteTextField.text) {
            let alert = UIAlertController(
                title: "Notify",
                message: "Your website address should be started with http:// or https://",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if let topVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                topVC.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        let url = self.snsOnboardingView.websiteTextField.text
        if url == "http://" || url == "https://" {
            UserInfo.shared.webUrl = ""
        } else{
            UserInfo.shared.webUrl = url
        }

        UserInfo.shared.instagramId = self.snsOnboardingView.instaTextField.text ?? ""
        UserInfo.shared.nationality = self.snsOnboardingView.selectedNationality.rawValue

        let talentOnboardingViewController = TalentOnboardingViewController()
        self.navigationController?.pushViewController(talentOnboardingViewController, animated: true)
    }
    
    func validateWebsite(_ website: String?) -> Bool {
        guard let website = website?.trimmingCharacters(in: .whitespacesAndNewlines),
              !website.isEmpty else {
            return true
        }
        
        if website.hasPrefix("http://") || website.hasPrefix("https://") {
            if let url = URL(string: website), UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        
        return false
    }
}

extension SNSOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
