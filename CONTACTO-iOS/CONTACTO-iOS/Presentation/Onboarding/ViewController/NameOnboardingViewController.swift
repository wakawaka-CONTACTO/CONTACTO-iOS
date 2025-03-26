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
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING1)
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
    
    override func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.ONBOARDING, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
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
            if let currentText = textField.text, !currentText.isEmpty, !currentText.isOnlyWhitespace() {
                nameOnboardingView.nextButton.isEnabled = true
            } else {
                nameOnboardingView.nextButton.isEnabled = false
            }
        }
    }
    
    @objc private func nextButtonTapped() {
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING1_NEXT)
        let name = nameOnboardingView.nameTextField.text ?? ""
            
        if !isValidName(name) {
            showInvalidNameAlert()
            return
        }
        UserInfo.shared.name = name
        let purposeOnboardingViewController = PurposeOnboardingViewController()
        self.navigationController?.pushViewController(purposeOnboardingViewController, animated: true)
    }
    
    private func isValidName(_ name: String) -> Bool {
        let regex = "^[a-zA-Z0-9가-힣]{2,20}$" // 2~20자의 영문자, 숫자, 한글만 허용
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: name)
    }
    
    private func showInvalidNameAlert() {
        let alertController = UIAlertController(
            title: "Error",
            message: "이름은 2~20자의 영문자, 숫자, 한글만 사용할 수 있습니다.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
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
