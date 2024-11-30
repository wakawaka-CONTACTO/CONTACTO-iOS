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
    }
    
    private func setLayout() {
        view.addSubviews(signUpView)
        
        signUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setAddTarget() {
        signUpView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        signUpView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeButton.addTarget(self, action: #selector(privacyAgreeButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeDetailButton.addTarget(self, action: #selector(privacyAgreeDetailButtonTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        signUpView.mainTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func continueButtonTapped() {
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
            if (!text.isEmpty || !text.isOnlyWhitespace()) {
                // email 정규식을 띄고 있다면
                self.email = text
                self.isTextFilled = true
            } else {
                self.isTextFilled = false
            }
        }
    }
}
