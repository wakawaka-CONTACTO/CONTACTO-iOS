//
//  LoginViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then

final class LoginViewController: UIViewController {
    
    private let loginView = LoginView(state: .email)
    var email = ""
    var password = ""
    var name = ""
    
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
        view.addSubviews(loginView)
        
        loginView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setAddTarget() {
        loginView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        loginView.newAccountButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginView.forgetEmailButton.addTarget(self, action: #selector(helpEmailButtonTapped), for: .touchUpInside)
        loginView.forgetPwButton.addTarget(self, action: #selector(helpPWButtonTapped), for: .touchUpInside)
        loginView.helpButton.addTarget(self, action: #selector(helpEmailButtonTapped), for: .touchUpInside)
        loginView.privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        loginView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        loginView.mainTextField.delegate = self
    }
    
    @objc func continueButtonTapped() {
        switch loginView.state {
        case .email, .emailError:
            loginView.mainTextField.text = ""
            loginView.setLoginState(state: .pw)
        case .pw, .pwError:
            loginButtonTapped()
        case .emailForget:
            loginView.mainTextField.text = ""
            loginView.setLoginState(state: .findEmail)
        case .pwForget:
            print("verify로 넘어감")
        case .findEmail:
            loginView.mainTextField.text = ""
            loginView.setLoginState(state: .email)
        }
    }
    
    @objc func loginButtonTapped() {
        // 성공한다면
        let mainTabBarViewController = MainTabBarViewController()
        view.window?.rootViewController = UINavigationController(rootViewController: mainTabBarViewController)
        // 실패하면 pwError
    }
    
    @objc func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: false)
    }
    
    @objc func backButtonTapped() {
        loginView.mainTextField.text = self.email
        loginView.setLoginState(state: .email)
    }
    
    @objc func helpEmailButtonTapped() {
        loginView.mainTextField.text = ""
        loginView.setLoginState(state: .emailForget)
    }
    
    @objc func helpPWButtonTapped() {
        loginView.mainTextField.text = ""
        loginView.setLoginState(state: .pwForget)
    }
    
    @objc private func privacyButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Network
    private func login(bodyDTO: LoginRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.login(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            if !text.isEmpty || !text.isOnlyWhitespace() {
                switch loginView.mainTextField.textFieldState {
                case .email:
                    self.loginView.continueButton.isEnabled = text.isValidEmail()
                    self.email = text
                    print(self.email)
                case .pw:
                    self.loginView.continueButton.isEnabled = true
                    self.password = text
                case .name:
                    self.loginView.continueButton.isEnabled = true
                    self.name = text
                case .findEmail:
                    print("텍스트에 이메일 뜹니다..")
                }
            } else {
                self.loginView.continueButton.isEnabled = false
            }
        }
    }
}
