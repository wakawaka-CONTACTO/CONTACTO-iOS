//
//  LoginBaseTextField.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/29/24.
//

import UIKit

@frozen enum textState {
    case email
    case name
    case pw
}

final class LoginBaseTextField: UITextField {
    
    var textFieldState = textState.email
    
    /// 보이면 true, 가려져있으면 false
    var isButtonTapped = false
    /// error면 true, 아니면 false
    var isError = false
    let eyeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(state: textState) {
        super.init(frame: CGRect())
        textFieldState = state
        setTextFieldState(state: state)
        setUI()
        setAddTarget()
    }
}

extension LoginBaseTextField {
    
    private func setAddTarget() {
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
    }
    
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setStyle() {
        self.do {
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
            $0.textAlignment = .center
            $0.backgroundColor = .ctwhite
            $0.autocapitalizationType = .none
            $0.returnKeyType = .done
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
        }
        
        eyeButton.do {
            $0.setImage(.icEye, for: .normal)
        }
    }
    
    private func setLayout() {
        self.addSubviews(eyeButton)
    }
    
    private func setTextFieldState(state: textState) {
        switch state {
        case .email:
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.email, forColor: .ctgray2)
            self.keyboardType = .emailAddress
            eyeButton.isHidden = false
        case .name:
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.name, forColor: .ctgray2)
            self.keyboardType = .asciiCapable
            eyeButton.isHidden = false
        case .pw:
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.pw, forColor: .ctgray2)
            self.keyboardType = .asciiCapable
            eyeButton.isHidden = true
        }
    }
    
    func errorText() {            self.setRoundBorder(borderColor: isError ? .ctblack : .ctsubred, borderWidth: 1.5, cornerRadius: 0)
    }
    
    @objc func eyeButtonTapped() {
        self.isButtonTapped.toggle()
        self.isSecureTextEntry = !isButtonTapped
        eyeButton.setImage(isButtonTapped ? .icEyeHide : .icEye, for: .normal)
    }
}
