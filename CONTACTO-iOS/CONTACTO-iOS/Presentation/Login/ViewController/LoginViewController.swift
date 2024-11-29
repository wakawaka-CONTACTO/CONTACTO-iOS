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
    
    private let loginView = LoginView()
    
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
//        loginView.continueButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
//        loginView.helpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginView.newAccountButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginView.privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
    }
    
    private func setDelegate() {
        loginView.mainTextField.delegate = self
    }
    
    @objc func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.navigationController?.pushViewController(signUpViewController, animated: false)
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
                self.loginView.continueButton.isEnabled = true
            } else {
                self.loginView.continueButton.isEnabled = false
            }
        }
    }
}
