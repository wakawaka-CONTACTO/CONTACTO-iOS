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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
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
    
    override func setAddTarget() {
        nameOnboardingView.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        nameOnboardingView.nameTextField.delegate = self
    }
}

extension NameOnboardingViewController {
    
    /// 노티피케이션 추가
    func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification){
        self.nameOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(325.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        self.nameOnboardingView.nextButton.snp.remakeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(55.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if let textField = sender as? UITextField {
            if let currentText = textField.text, !currentText.isEmpty, !currentText.isOnlyWhitespace() {
                nameOnboardingView.nextButton.isEnabled = true
            } else {
                nameOnboardingView.nextButton.isEnabled = false
            }
        }
    }
    
    @objc private func nextButtonTapped() {
        let purposeOnboardingViewController = PurposeOnboardingViewController()
        self.navigationController?.pushViewController(purposeOnboardingViewController, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let utf8Char = string.cString(using: .utf8)
        let isBackSpace = strcmp(utf8Char, "\\b")
        
        if !string.isEmpty || isBackSpace == -92  {
//            if string.hasCharacters() {
                guard let textFieldText = textField.text,
                      let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
                }
                
                let newText = textFieldText.replacingCharacters(in: rangeOfTextToReplace, with: string)
                let count = newText.count
                return count <= 20
//            } else {
//                return false
//            }
        }
        return false
    }
}

extension NameOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
