//
//  ExplainOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class ExplainOnboardingViewController: BaseViewController, OnboadingAmplitudeSender {
    
    let explainOnboardingView = ExplainOnboardingView()
    var explain = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING3)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setLayout() {
        view.addSubviews(explainOnboardingView)
        
        explainOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        explainOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        explainOnboardingView.explainTextView.delegate = self
    }
}

extension ExplainOnboardingViewController {
    
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
        
        self.explainOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(317.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        self.explainOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(55.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func nextButtonTapped() {
        UserInfo.shared.description = explainOnboardingView.explainTextView.text ?? ""
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING3_NEXT)
        let SNSOnboardingViewController = SNSOnboardingViewController()
        self.navigationController?.pushViewController(SNSOnboardingViewController, animated: true)
    }
}

extension ExplainOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ExplainOnboardingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == StringLiterals.Onboarding.Explain.example {
            textView.text = nil
            textView.textColor = .ctblack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = StringLiterals.Onboarding.Explain.example
            textView.textColor = .ctgray2
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty, textView.text != StringLiterals.Onboarding.Explain.example, !textView.text.isOnlyWhitespace() {
            explainOnboardingView.nextButton.isEnabled = true
        } else {
            explainOnboardingView.nextButton.isEnabled = false
        }
    }
}

