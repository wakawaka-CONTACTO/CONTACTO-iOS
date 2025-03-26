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

final class SignUpViewController: UIViewController {
    
    let signUpView = SignUpView()
    let emailCodeView = EmailCodeView()
    let setPWView = SetPassWordView()
    var email = ""
    var pw = ""
    var confirmPw = ""
    var authCode = ""
    var nationality = ""
    
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
    }
    
    private func setDelegate() {
        signUpView.mainTextField.delegate = self
        emailCodeView.mainTextField.delegate = self
        setPWView.mainTextField.delegate = self
        setPWView.confirmTextField.delegate = self
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.LOGIN, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }
}

extension SignUpViewController {
    @objc private func sendCode() {
        sendAmpliLog(eventName: EventName.CLICK_EMAIL_CODE_RESEND)
        NetworkService.shared.onboardingService.emailSend(bodyDTO: EmailSendRequestBodyDTO(email: self.email)) { result in DispatchQueue.main.async {
            switch result{
            case .success:
                self.signUpView.isHidden = true
                self.emailCodeView.isHidden = false
                self.setPWView.isHidden = true
                self.emailCodeView.startTimer()
            case .failure(let error):
                var errorMessage = "이메일 전송에 실패했습니다. 잠시후 다시 시도해주세요."
                if let data = error.data,
                   let errorResponse = try? JSONDecoder().decode(ErrorResponse<[String]>.self, from: data){
                    errorMessage = errorResponse.message
                }
                let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true, completion: nil)
                self.signUpView.mainTextField.isError = true
            default:
                var errorMessage = "이메일 전송에 실패했습니다. 관리자에게 문의해주세요."
                let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true, completion: nil)
                self.signUpView.mainTextField.text = ""
                self.signUpView.mainTextField.isError = true
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        sendAmpliLog(eventName: EventName.CLICK_SIGNUP_BACK)
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc private func privacyAgreeButtonTapped() {
        sendAmpliLog(eventName: EventName.CLICK_SIGNUP_AGREE)
        isPrivacyAgree.toggle()
    }
    
    @objc private func privacyAgreeDetailButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        sendAmpliLog(eventName: EventName.CLICK_SIGNUP_AGREE_DETAIL)
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc private func codeVerifyButtonTapped() {
        emailCheck(bodyDTO: EmailCheckRequestBodyDTO(email: self.email, authCode: self.authCode)) { response in
            if response {
                self.signUpView.isHidden = true
                self.emailCodeView.isHidden = true
                self.setPWView.isHidden = false
            } else {
                self.emailCodeView.underLineView.image = .imgUnderLineRed
            }
        }
    }
    
    @objc private func pwContinueButton() {
        UserInfo.shared.email = self.email
        UserInfo.shared.password = self.pw
        sendAmpliLog(eventName: EventName.CLICK_SIGNUP_CONTINUE)
        let nameOnboardingViewController = NameOnboardingViewController()
        view.window?.rootViewController = UINavigationController(rootViewController: nameOnboardingViewController)
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
    
    private func emailCheck(bodyDTO: EmailCheckRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        sendAmpliLog(eventName: EventName.CLICK_EMAIL_CODE_NEXT)
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
                if (!text.isEmpty || !text.isOnlyWhitespace()) {
                    if text.isValidEmail() {
                        self.email = text
                        self.isTextFilled = true
                    } else {
                        self.isTextFilled = false
                    }
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
