//
//  SignUpViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/29/24.
//

import UIKit

import SnapKit
import Then

final class SignUpViewController: UIViewController {
    
    let signUpView = SignUpView()
    let emailCodeView = EmailCodeView()
    let setPWView = SetPassWordView()
    var email = ""
    
    var isPrivacyAgree = false {
        didSet {
            signUpView.privacyAgreeButton.setImage(isPrivacyAgree ? .icChecked : .icNotChecked, for: .normal)
            if isTextFilled, isPrivacyAgree {
                signUpView.continueButton.isEnabled = true
            } else {
                signUpView.continueButton.isEnabled = false
            }
        }
    }
    
    var isTextFilled = false {
        didSet {
            if isTextFilled, isPrivacyAgree {
                signUpView.continueButton.isEnabled = true
            } else {
                signUpView.continueButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegate()
        setAddTarget()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
    }
    
    // MARK: UI
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        view.backgroundColor = .ctblack
        
        signUpView.isHidden = false
        emailCodeView.isHidden = true
        setPWView.isHidden = true
    }
    
    private func setLayout() {
        view.addSubviews(signUpView,
                         emailCodeView,
                         setPWView)
        
        signUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emailCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        setPWView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setAddTarget() {
        signUpView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        signUpView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeButton.addTarget(self, action: #selector(privacyAgreeButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeDetailButton.addTarget(self, action: #selector(privacyAgreeDetailButtonTapped), for: .touchUpInside)
        
        emailCodeView.continueButton.addTarget(self, action: #selector(codeVerifyButtonTapped), for: .touchUpInside)
        emailCodeView.resendButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
    }
    
    private func setDelegate() {
        signUpView.mainTextField.delegate = self
        emailCodeView.mainTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension SignUpViewController {
    @objc private func continueButtonTapped() {
        sendCode()
        signUpView.isHidden = true
        emailCodeView.isHidden = false
        setPWView.isHidden = true
    }
    
    @objc private func sendCode() {
        print("continue: 이메일 인증번호 보내기")
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc private func privacyAgreeButtonTapped() {
        isPrivacyAgree.toggle()
    }
    
    @objc private func privacyAgreeDetailButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func codeVerifyButtonTapped() {
        // 맞다면 reset view로 바꾸기
        signUpView.isHidden = true
        emailCodeView.isHidden = true
        setPWView.isHidden = false
    }
}

extension SignUpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            switch textField {
            case signUpView.mainTextField:
                if (!text.isEmpty || !text.isOnlyWhitespace()) {
                    if text.isValidEmail() {
                        self.email = text
                        self.isTextFilled = true
                    } else {
                        self.isTextFilled = false
                    }
                }
            case emailCodeView.mainTextField:
                print(text)
            default:
                print("hello")
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailCodeView.mainTextField {
            let currentText = (textField.text ?? "") as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            guard updatedText.count <= 6 else {
                return false
            }
            
            let attributedString = NSMutableAttributedString(string: updatedText)
            let textLength = updatedText.count
            
            if textLength > 1 {
                attributedString.addAttribute(.kern, value: 35, range: NSRange(location: 0, length: textLength - 1))
            }
            
            attributedString.addAttribute(.font, value: UIFont.fontContacto(.number), range: NSRange(location: 0, length: textLength))
            textField.attributedText = attributedString
            emailCodeView.continueButton.isEnabled = (textLength == 6)
            return false
        } else {
            return true
        }
    }

}
