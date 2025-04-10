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
import FirebaseMessaging

final class LoginViewController: UIViewController, LoginAmplitudeSender{
    
    var loginView: LoginView
    private let emailCodeView = EmailCodeView()
    private let setPWView = SetPassWordView()
    var email = ""
    var pw = ""
    var confirmPw = ""
    var name = ""
    var decodeEmail = ""
    var authCode = ""
    
    var isExistEmail = false
    var purpose =  EmailSendPurpose.signup
    weak var delegate: EmailCodeViewDelegate?
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
    
    // 로딩 인디케이터: 전체 화면 오버레이
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor(white: 0, alpha: 0.3)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init() {
        self.loginView = LoginView(state: .email)
        super.init(nibName: nil, bundle: nil)
        failCount = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                         setPWView,
                         activityIndicator)
        
        loginView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emailCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        setPWView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
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
        emailCodeView.delegate = self
        setPWView.mainTextField.delegate = self
        setPWView.confirmTextField.delegate = self
    }
}

extension LoginViewController {
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

extension LoginViewController {
    @objc func continueButtonTapped() {
        switch loginView.state {
        case .email, .emailError:
            showLoadingIndicator()
            if loginView.state == .email {
                self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_CONTINUE)
            } else{
                self.sendAmpliLog(eventName: EventName.CLICK_NOACCOUNT_CONTINUE)
            }
            emailExist(queryDTO: EmailExistRequestQueryDTO(email: loginView.mainTextField.text ?? "")) { _ in
                if self.isExistEmail {
                    self.loginView.mainTextField.text = ""
                    self.loginView.setLoginState(state: .pw)
                } else {
                    self.loginView.setLoginState(state: .emailError)
                }
            }
            hideLoadingIndicator()
        case .pw, .pwError:
            showLoadingIndicator()
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            let deviceType = UIDevice.current.model
            if loginView.state == .pw{
                self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_BUTTON)
            } else{
                self.sendAmpliLog(eventName: EventName.CLICK_INCORRECT_LOGIN)
            }
            // FCM 토큰 비동기 처리
            Messaging.messaging().token { firebaseToken, error in
                guard let firebaseToken = firebaseToken else {
                    self.view.showToast(message: "FCM 토큰을 가져올 수 없습니다")
                    return
                }
                
                // 로그인 요청에 디바이스 정보 포함
                let bodyDTO = LoginRequestBodyDTO(
                    email: self.email,
                    password: self.pw,
                    firebaseToken: firebaseToken,
                    deviceId: deviceId,
                    deviceType: deviceType
                )
                
                self.login(bodyDTO: bodyDTO) { response in
                    if response {
                        let mainTabBarViewController = MainTabBarViewController()
                        mainTabBarViewController.homeViewController.isFirst = false
                        self.view.window?.rootViewController = UINavigationController(rootViewController: mainTabBarViewController)
                    }
                }
                self.hideLoadingIndicator()
            }
                
        case .emailForget:
            self.sendAmpliLog(eventName: EventName.CLICK_INPUT_NAME_CONTINUE)
            helpEmail(bodyDTO: SignInHelpRequestBodyDTO(userName: self.name)) { _ in
                self.loginView.mainTextField.text = ""
                self.loginView.mainTextField.changePlaceholderColor(forPlaceHolder: self.decodeEmail, forColor: .ctgray2)
        }
        case .pwForget:
            self.sendAmpliLog(eventName: EventName.CLICK_SEND_CODE_CONTINUE)
            emailExist(queryDTO: EmailExistRequestQueryDTO(email: loginView.mainTextField.text ?? "")) { _ in
                if self.isExistEmail {
                    self.sendCode()
                } else {
                    self.loginView.setExplain(description: "Cannot find your email.")
                    self.loginView.mainTextField.text = ""
                    self.loginView.setLoginState(state: .pwForget)
                }
            }
            
        case .findEmail:
            loginView.mainTextField.text = ""
            loginView.setLoginState(state: .email)
        }
    }
    
    @objc func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: false)
        self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_CREATE)
    }
    
    @objc func helpEmailButtonTapped() {
        loginView.mainTextField.text = ""
        self.decodeEmail = ""
        if loginView.state == .email {
            self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_NEEDHELP)
        } else if loginView.state == .emailError{
            self.sendAmpliLog(eventName: EventName.CLICK_NOACCOUNT_FORGET)
        }
        loginView.setLoginState(state: .emailForget)
    }
    
    @objc func helpPWButtonTapped() {
        loginView.mainTextField.text = ""
        if loginView.state == .email || loginView.state == .emailError{
            self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_NEEDHELP)
        } else if loginView.state == .pwError {
            self.sendAmpliLog(eventName: EventName.CLICK_INCORRECT_FORGET)
        } else if loginView.state == .emailForget {
            self.sendAmpliLog(eventName: EventName.CLICK_INPUT_NAME_FORGET)
        }
        loginView.setLoginState(state: .pwForget)
        
    }
    
    @objc private func privacyButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }

    @objc private func codeVerifyButtonTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_SEND_CODE_CONTINUE)
        emailCheck(bodyDTO: EmailCheckRequestBodyDTO(email: self.email, authCode: self.authCode)) { response in
            if response {
                self.loginView.isHidden = true
                self.emailCodeView.isHidden = true
                self.setPWView.isHidden = false
                self.sendAmpliLog(eventName: EventName.VIEW_RESET_PASSWORD)
            } else {
                self.emailCodeView.underLineView.image = .imgUnderLineRed
            }
        }
    }
    
    @objc private func sendCode() {
        self.purpose = EmailSendPurpose.reset
        self.dismissKeyboard()
        self.emailCodeView.startTimer()
        emailSend(bodyDTO: EmailSendRequestBodyDTO(email: self.email, purpose: self.purpose)) { _ in            self.loginView.isHidden = true
            self.emailCodeView.isHidden = false
            self.setPWView.isHidden = true
        }
        self.purpose = EmailSendPurpose.signup
    }
    
    @objc private func pwContinueButton() {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = UIDevice.current.model
        self.sendAmpliLog(eventName: EventName.CLICK_SET_PASSWORD_NEXT)
        // FCM 토큰 비동기 처리
        Messaging.messaging().token { firebaseToken, error in
            guard let firebaseToken = firebaseToken else {
                self.view.showToast(message: "FCM 토큰을 가져올 수 없습니다")
                return
            }
            
            // 로그인 요청에 디바이스 정보 포함
            let bodyDTO = LoginRequestBodyDTO(
                email: self.email,
                password: self.pw,
                firebaseToken: firebaseToken,
                deviceId: deviceId,
                deviceType: deviceType
            )
            
            self.updatePwd(bodyDTO: bodyDTO) { response in
                if response {
                    self.view.showToast(message: "Your Password is updated successfully!")
                    let loginVC = LoginViewController()
                    self.navigationController?.setViewControllers([loginVC], animated: false)
                } else {
                    self.view.showToast(message: "Something went wrong. Try Again")
                }
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
                KeychainHandler.shared.userID = String(data.userId)
                KeychainHandler.shared.accessToken = data.accessToken
                KeychainHandler.shared.refreshToken = data.refreshToken
                UserIdentityManager.setUserId()
                self.sendAmpliLog(eventName: EventName.SUCCESS_LOGIN)
                completion(true)
            case .failure(let error):
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data) {
                    DispatchQueue.main.async {
                        self.view.showToast(message: errorResponse.message)
                    }
                }
                self.loginView.setLoginState(state: .pwError)
                completion(false)
            default:
                self.loginView.setLoginState(state: .pwError)
                completion(false)
            }
        }
    }
    
    private func helpEmail(bodyDTO: SignInHelpRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.signHelp(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                self?.decodeEmail = data.decodeEmail
                DispatchQueue.main.async {
                    self?.loginView.setLoginState(state: .findEmail)
                    self?.loginView.mainTextField.text = data.decodeEmail
                }
                completion(true)
            case .failure(let error):
                if error.statusCode == 404 {
                    DispatchQueue.main.async {
                        //self?.loginView.setLoginState(state: .emailForget)
                        self?.view.showToast(message: "The user name does not exist.")
                        self?.loginView.mainTextField.isError = true
                    }
                }
                completion(false)
            default:
                completion(false)
            }
        }
    }
    
    private func emailSend(bodyDTO: EmailSendRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        if self.isFirst() == true{
            self.sendAmpliLog(eventName: EventName.VIEW_EMAIL_CODE, properties: ["sendcode_view": "forget password view"])
            self.retry()
        } else {
            self.sendAmpliLog(eventName: EventName.CLICK_EMAIL_CODE_RESEND)
            self.retry()
        }
        
        NetworkService.shared.onboardingService.emailSend(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(_):
                self.emailCodeView.setStatus()
                self.emailCodeView.startTimer()
                completion(true)
            default:
                self.retry()
                completion(false)
            }
        }
    }
    
    private func emailCheck(bodyDTO: EmailCheckRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.emailCheck(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                self.sendAmpliLog(eventName: EventName.CLICK_EMAIL_CODE_NEXT)
                completion(data.isSuccess)
            default:
                self.emailCodeView.setFail()
                completion(false)
            }
        }
    }
    
    private func emailExist(queryDTO: EmailExistRequestQueryDTO, completion: @escaping (Bool) -> Void) {
        self.isExistEmail = false 
        NetworkService.shared.onboardingService.emailExist(queryDTO: queryDTO) { response in
            switch response {
            case .success(_):
                self.isExistEmail = true
                completion(true)
                
            case .failure(let error):
                // 그 외 에러
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data) {
                    DispatchQueue.main.async {
                        self.view.showToast(message: errorResponse.message)
                    }
                }
                completion(false)
                
            default:
                completion(false)
            }
        }
    }
    
    private func updatePwd(bodyDTO: LoginRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        self.sendAmpliLog(eventName: EventName.CLICK_RESET_PASSWORD_NEXT)
        NetworkService.shared.onboardingService.updatePwd(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                completion(data.isSuccess)
            default:
                completion(false)
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
                    case .pw:
                        self.loginView.continueButton.isEnabled = true
                        self.pw = text
                    case .name:
                        self.loginView.continueButton.isEnabled = true
                        self.name = text
                    case .findEmail:
                        #if DEBUG
                        print("텍스트에 이메일 뜹니다..")
                        #endif
                    }
                } else {
                    self.loginView.continueButton.isEnabled = false
                }
                
            case emailCodeView.mainTextField:
                self.authCode = text
                
            case setPWView.mainTextField:
                setPWView.conditionViewLetter.isSatisfied = text.isMinimumLength(textField.text ?? "")
                setPWView.conditionViewSpecial.isSatisfied = text.containsSpecialCharacter(textField.text ?? "")
                setPWView.conditionViewNum.isSatisfied = text.containsNumber(textField.text ?? "")
                
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

extension LoginViewController: EmailCodeViewDelegate {
    @objc func timerDidFinish(_ view: EmailCodeView) {    }
    
    @objc internal func backButtonTapped() {
        let loginVC = LoginViewController()
        if loginView.state == .emailForget{
            self.sendAmpliLog(eventName: EventName.CLICK_INPUT_NAME_GO_TO_LOGIN)
        }
        else{
            self.sendAmpliLog(eventName: EventName.CLICK_LOGIN_FIRST_STEP)
        }
        
        self.navigationController?.setViewControllers([loginVC], animated: false)
    }
}
