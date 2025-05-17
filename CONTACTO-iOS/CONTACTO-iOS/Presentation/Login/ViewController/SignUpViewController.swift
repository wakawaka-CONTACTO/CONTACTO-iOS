//
//  SignUpViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/29/24.
//

import UIKit

import SnapKit
import Then
import SafariServices

final class SignUpViewController: UIViewController, LoginAmplitudeSender {
    
    let signUpView = SignUpView()
    let emailCodeView = EmailCodeView()
    let setPWView = SetPassWordView()
    var email = ""
    var pw = ""
    var confirmPw = ""
    var authCode = ""
    var nationality = ""
    private var failCount: Int = 0
    
    public func isFirst() -> Bool{
        if self.failCount == 0 {
            return true
        }
        return false
    }
    public func retry() {
        self.failCount += 1
    }
    
    weak var delegate: EmailCodeViewDelegate?

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
        signUpView.continueButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        signUpView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeButton.addTarget(self, action: #selector(privacyAgreeButtonTapped), for: .touchUpInside)
        signUpView.privacyAgreeDetailButton.addTarget(self, action: #selector(privacyAgreeDetailButtonTapped), for: .touchUpInside)
        
        emailCodeView.continueButton.addTarget(self, action: #selector(codeVerifyButtonTapped), for: .touchUpInside)
        emailCodeView.resendButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        
        setPWView.continueButton.addTarget(self, action: #selector(pwContinueButton), for: .touchUpInside)
        self.sendAmpliLog(eventName: EventName.VIEW_SIGNUP)
    }
    
    private func setDelegate() {
        signUpView.mainTextField.delegate = self
        emailCodeView.mainTextField.delegate = self
        emailCodeView.delegate = self
        setPWView.mainTextField.delegate = self
        setPWView.confirmTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}

extension SignUpViewController {
    private func validateEmail(bodyDTO: EmailValidationRequest, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.validateEmail(bodyDTO: bodyDTO) { response in
            switch response {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure:
                // 400, 404 등의 에러 응답을 받은 경우
                DispatchQueue.main.async {
                    self.showValidationError(message: StringLiterals.Onboarding.Error.invalidEmail)
                    completion(false)
                }
            default:
                DispatchQueue.main.async {
                    self.showValidationError(message: StringLiterals.Onboarding.Error.serverError)
                    completion(false)
                }
            }
        }
    }

    private func validatePassword(bodyDTO: PasswordValidationRequest, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.validatePassword(bodyDTO: bodyDTO) { response in
            switch response {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure:
                // 400, 404 등의 에러 응답을 받은 경우
                DispatchQueue.main.async {
                    self.showValidationError(message: StringLiterals.Onboarding.Error.invalidPassword)
                    completion(false)
                }
            default:
                DispatchQueue.main.async {
                    self.showValidationError(message: StringLiterals.Onboarding.Error.serverError)
                    completion(false)
                }
            }
        }
    }
    
    private func showValidationError(message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc private func sendCode() {
        self.signUpView.continueButton.isEnabled = false
        self.dismissKeyboard()
        validateEmail(bodyDTO: EmailValidationRequest(email: self.email)) { [weak self] isValid in
            guard let self = self else { return }
            
            if !isValid {
                self.signUpView.continueButton.isEnabled = true
                return
            }
            
            if self.signUpView.isHidden == false {
                KeychainHandler.shared.userName = self.email
                self.sendAmpliLog(eventName: EventName.CLICK_SIGNUP_CONTINUE)
            }
            
            UserIdentityManager.setUserId(userId: self.email, status: "UNKNOWN")
            
            EmailVerificationManager.shared.startVerification(
                email: self.email,
                purpose: .signup
            ) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.signUpView.isHidden = true
                        self?.emailCodeView.isHidden = false
                        self?.setPWView.isHidden = true
                        self?.emailCodeView.startTimer()
                        self?.emailCodeView.setStatus()
                    } else {
                        self?.signUpView.mainTextField.isError = true
                        self?.signUpView.continueButton.isEnabled = true
                        self?.emailCodeView.setFail()
                    }
                }
            }
        }
    }
    
    @objc private func privacyAgreeButtonTapped() {
        isPrivacyAgree.toggle()
        self.sendAmpliLog(eventName: EventName.CLICK_SIGNUP_AGREE)
    }
    
    @objc private func privacyAgreeDetailButtonTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_SIGNUP_AGREE_DETAIL)
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc private func codeVerifyButtonTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_EMAIL_CODE_NEXT)
        EmailVerificationManager.shared.verifyCode(authCode) { [weak self] success, _ in
            if success {
                self?.signUpView.isHidden = true
                self?.emailCodeView.isHidden = true
                self?.setPWView.isHidden = false
                self?.sendAmpliLog(eventName: EventName.VIEW_SET_PASSWORD)
            } else {
                self?.emailCodeView.underLineView.image = .imgUnderLineRed
                self?.emailCodeView.setFail()
            }
        }
    }
    
    @objc private func pwContinueButton() {
        let validateRequest = PasswordValidationRequest(password: self.pw)
        validatePassword(bodyDTO: validateRequest) { [weak self] isValid in
            guard let self = self else { return }
            
            if isValid {
                UserInfo.shared.email = self.email
                UserInfo.shared.password = self.pw
                let nameOnboardingViewController = NameOnboardingViewController()
                self.view.window?.rootViewController = UINavigationController(rootViewController: nameOnboardingViewController)
            }
        }
    }
    
    private func changePWButton() {
        if setPWView.conditionViewLetter.isSatisfied,
           setPWView.conditionViewSpecial.isSatisfied,
           setPWView.conditionViewNum.isSatisfied,
           setPWView.conditionViewAlphabet.isSatisfied,
            self.pw == self.confirmPw {
            setPWView.continueButton.isEnabled = true
        } else {
            setPWView.continueButton.isEnabled = false
        }
    }
    
    private func emailCheck(bodyDTO: EmailCheckRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.emailCheck(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                completion(data.isSuccess)
            default:
                completion(false)
            }
        }
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
                if text.isEmpty || text.isOnlyWhitespace() {
                    self.email = ""
                    self.isTextFilled = false
                    return
                }
                
                if text.isValidEmail() {
                    self.email = text
                    self.isTextFilled = true
                } else {
                    self.email = text
                    self.isTextFilled = false
                }
                
            case emailCodeView.mainTextField:
                self.authCode = text
                
            case setPWView.mainTextField:
                setPWView.conditionViewLetter.isSatisfied = text.isMinimumLength(textField.text ?? "")
                setPWView.conditionViewSpecial.isSatisfied = text.containsSpecialCharacter(textField.text ?? "")
                setPWView.conditionViewNum.isSatisfied = text.containsNumber(textField.text ?? "")
                setPWView.conditionViewAlphabet.isSatisfied = text.containsAlphabet(textField.text ?? "")
                
                self.pw = textField.text ?? ""
                changePWButton()
                
            case setPWView.confirmTextField:
                self.confirmPw = textField.text ?? ""
                changePWButton()
                
            default:
                #if DEBUG
                print("default")
                #endif
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
                attributedString.addAttribute(.kern, value: adjustedValueForiPhone16Pro(), range: NSRange(location: 0, length: textLength - 1))
            }
            
            attributedString.addAttribute(.font, value: UIFont.fontContacto(.number), range: NSRange(location: 0, length: textLength))
            textField.attributedText = attributedString
            emailCodeView.continueButton.isEnabled = (textLength == 6)
            return false
            
        default:
            return true
        }
    }
    
    
    func adjustedValueForiPhone16Pro() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let iPhone16ProWidth: CGFloat = 393

        if screenWidth >= iPhone16ProWidth {
            return 40.adjustedWidth
        } else {
            return 42.adjustedWidth
        }
    }
}

extension SignUpViewController: EmailCodeViewDelegate {
    @objc func timerDidFinish(_ view: EmailCodeView) {    }
    
    @objc internal func backButtonTapped() {
        // 로그인 화면으로 이동
        let loginVC = LoginViewController()
        self.navigationController?.setViewControllers([loginVC], animated: false)
        self.sendAmpliLog(eventName: EventName.CLICK_SIGNUP_BACK)
    }
}
