//
//  LoginViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

import SnapKit
import Then
import SafariServices

final class LoginViewController: UIViewController {
    
    private let loginView = LoginView(state: .email)
    private let emailCodeView = EmailCodeView()
    private let setPWView = SetPassWordView()
    var email = ""
    var pw = ""
    var confirmPw = ""
    var name = ""
    var decodeEmail = ""
    var authCode = ""
    
    var isExistEmail = false
    
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
        
        loginView.isHidden = false
        emailCodeView.isHidden = true
        
        setPWView.do {
            $0.isHidden = true
            $0.descriptionLabel.text = StringLiterals.Login.resetPW
        }
    }
    
    private func setLayout() {
        view.addSubviews(loginView,
                         emailCodeView,
                         setPWView)
        
        loginView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emailCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        setPWView.snp.makeConstraints {
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
        
        emailCodeView.continueButton.addTarget(self, action: #selector(codeVerifyButtonTapped), for: .touchUpInside)
        emailCodeView.resendButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        
        setPWView.continueButton.addTarget(self, action: #selector(pwContinueButton), for: .touchUpInside)
    }
    
    private func setDelegate() {
        loginView.mainTextField.delegate = self
        emailCodeView.mainTextField.delegate = self
        setPWView.mainTextField.delegate = self
        setPWView.confirmTextField.delegate = self
    }
}

extension LoginViewController {
    @objc func continueButtonTapped() {
        switch loginView.state {
        case .email, .emailError:
            emailExist(queryDTO: EmailExistRequestQueryDTO(email: loginView.mainTextField.text ?? "")) { _ in
                if self.isExistEmail {
                    self.loginView.mainTextField.text = ""
                    self.loginView.setLoginState(state: .pw)
                } else {
                    self.loginView.mainTextField.text = ""
                    self.loginView.setLoginState(state: .emailError)
                }
            }
        case .pw, .pwError:
            login(bodyDTO: LoginRequestBodyDTO(email: self.email, password: self.pw)) { result in
                if result {
                    let mainTabBarViewController = MainTabBarViewController()
                    mainTabBarViewController.homeViewController.isFirst = false
                    self.view.window?.rootViewController = UINavigationController(rootViewController: mainTabBarViewController)
                }
            }
        case .emailForget:
            helpEmail(bodyDTO: SignInHelpRequestBodyDTO(userName: self.name)) { _ in
                self.loginView.mainTextField.text = ""
                self.loginView.setLoginState(state: .findEmail)
                self.loginView.mainTextField.changePlaceholderColor(forPlaceHolder: self.decodeEmail, forColor: .ctgray2)
        }
        case .pwForget:
            sendCode()
            
        case .findEmail:
            loginView.mainTextField.text = ""
            loginView.setLoginState(state: .email)
        }
    }
    
    @objc func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: false)
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
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
        loginView.mainTextField.text = self.email
        loginView.setLoginState(state: .email)
    }
    
    @objc private func codeVerifyButtonTapped() {
        emailCheck(bodyDTO: EmailCheckRequestBodyDTO(email: self.email, authCode: self.authCode)) { _ in
            self.loginView.isHidden = true
            self.emailCodeView.isHidden = true
            self.setPWView.isHidden = false
        }
    }
    
    @objc private func sendCode() {
        print("continue: 이메일 인증번호 보내기")
        emailSend(bodyDTO: EmailSendRequestBodyDTO(email: self.email)) { _ in
            self.loginView.isHidden = true
            self.emailCodeView.isHidden = false
            self.setPWView.isHidden = true
        }
    }
    
    @objc private func pwContinueButton() {
        updatePwd(bodyDTO: LoginRequestBodyDTO(email: self.email, password: self.pw)) { response in
            if response {
                let mainTabBarViewController = MainTabBarViewController()
                mainTabBarViewController.homeViewController.isFirst = false
                self.view.window?.rootViewController = UINavigationController(rootViewController: mainTabBarViewController)
            }
        }
    }
    
    private func changePWButton() {
        if setPWView.conditionViewLetter.isSatisfied,
           setPWView.conditionViewSpecial.isSatisfied,
           setPWView.conditionViewNum.isSatisfied,
            self.pw == self.confirmPw {
            setPWView.continueButton.isEnabled = true
        } else {
            setPWView.continueButton.isEnabled = false
        }
    }
    
    // MARK: - Network
    private func login(bodyDTO: LoginRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.login(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
//                if let data = data, status < 300 {
                    KeychainHandler.shared.userID = String(data.userId)
                    KeychainHandler.shared.accessToken = data.accessToken
                    KeychainHandler.shared.refreshToken = data.refreshToken
                    completion(true)
//                } else if status == 401 {
//                    self.loginView.setLoginState(state: .pwError)
//                    completion(false)
//                }
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func helpEmail(bodyDTO: SignInHelpRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.signHelp(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                self?.decodeEmail = data.decodeEmail
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func emailSend(bodyDTO: EmailSendRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.emailSend(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(_):
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func emailCheck(bodyDTO: EmailCheckRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.emailCheck(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                completion(data)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func emailExist(queryDTO: EmailExistRequestQueryDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.emailExist(queryDTO: queryDTO) { response in
            switch response {
            case .success(let data):
                if data?.status == "NOT_FOUND" {
                    self.isExistEmail = false
                    completion(true)
                }
                
//                if status == 200 {
//                    self.isExistEmail = true
//                    completion(true)
//                }
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func updatePwd(bodyDTO: LoginRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.updatePwd(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(_):
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
            
            switch textField {
            case loginView.mainTextField:
                if !text.isEmpty || !text.isOnlyWhitespace() {
                    switch loginView.mainTextField.textFieldState {
                    case .email:
                        self.loginView.continueButton.isEnabled = text.isValidEmail()
                        self.email = text
                        print(self.email)
                    case .pw:
                        self.loginView.continueButton.isEnabled = true
                        self.pw = text
                    case .name:
                        self.loginView.continueButton.isEnabled = true
                        self.name = text
                    case .findEmail:
                        print("텍스트에 이메일 뜹니다..")
                    }
                } else {
                    self.loginView.continueButton.isEnabled = false
                }
                
            case emailCodeView.mainTextField:
                self.authCode = text
                print(text)
                
            case setPWView.mainTextField:
                print(text)
                setPWView.conditionViewLetter.isSatisfied = text.isMinimumLength(textField.text ?? "")
                setPWView.conditionViewSpecial.isSatisfied = text.containsSpecialCharacter(textField.text ?? "")
                setPWView.conditionViewNum.isSatisfied = text.containsNumber(textField.text ?? "")
                
                self.pw = textField.text ?? ""
                changePWButton()
                
            case setPWView.confirmTextField:
                print(text)
                self.confirmPw = textField.text ?? ""
                changePWButton()
                
            default:
                print("default")
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case emailCodeView.mainTextField:
            let currentText = (textField.text ?? "") as NSString
            let updatedText = currentText.replacingCharacters(in: range, with: string)
            
            guard updatedText.count <= 6 else {
                return false
            }
            
            let attributedString = NSMutableAttributedString(string: updatedText)
            let textLength = updatedText.count
            
            if textLength > 1 {
                attributedString.addAttribute(.kern, value: 36, range: NSRange(location: 0, length: textLength - 1))
            }
            
            attributedString.addAttribute(.font, value: UIFont.fontContacto(.number), range: NSRange(location: 0, length: textLength))
            textField.attributedText = attributedString
            emailCodeView.continueButton.isEnabled = (textLength == 6)
            return false
            
        default:
            return true
        }
    }
}
