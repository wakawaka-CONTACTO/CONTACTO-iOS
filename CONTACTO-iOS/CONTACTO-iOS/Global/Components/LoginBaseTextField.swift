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
    case findEmail
}

final class LoginBaseTextField: BaseTextField {
    
    var textFieldState = textState.email
    
    /// 보이면 true, 가려져있으면 false
    var isButtonTapped = false
    /// error면 true, 아니면 false
    var isError = false {
        didSet {
            errorText()
        }
    }
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
        setTextFieldState(state: state)
        setUI()
    }
}

extension LoginBaseTextField {
    
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
            $0.isUserInteractionEnabled = true
        }
    }
    
    private func setLayout() {
        self.addSubviews(eyeButton)
        
        eyeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    func setTextFieldState(state: textState) {
        self.textFieldState = state
        switch state {
        case .email:
            self.backgroundColor = .ctwhite
            self.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            self.textColor = .ctblack
            self.isEnabled = true
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.email, forColor: .ctgray2)
            self.keyboardType = .emailAddress
            self.isSecureTextEntry = false
            eyeButton.isHidden = true
            
        case .name:
            self.backgroundColor = .ctwhite
            self.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            self.textColor = .ctblack
            self.isEnabled = true
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.name, forColor: .ctgray2)
            self.keyboardType = .asciiCapable
            self.isSecureTextEntry = false
            eyeButton.isHidden = true
            
        case .pw:
            self.backgroundColor = .ctwhite
            self.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            self.textColor = .ctblack
            self.isEnabled = true
            self.changePlaceholderColor(forPlaceHolder: StringLiterals.Login.pw, forColor: .ctgray2)
            self.keyboardType = .asciiCapable
            self.isSecureTextEntry = true
            eyeButton.isHidden = false
            
        case .findEmail:
            self.backgroundColor = .clear
            self.setRoundBorder(borderColor: .ctwhite, borderWidth: 1.5, cornerRadius: 0)
            self.textColor = .ctwhite
            self.changePlaceholderColor(forPlaceHolder: "", forColor: .ctgray2)
            self.isEnabled = false
            self.isSecureTextEntry = false
            eyeButton.isHidden = true
        }
    }
    
    func errorText() {            
        self.setRoundBorder(borderColor: isError ? .ctsubred : .ctblack, borderWidth: 1.5, cornerRadius: 0)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if eyeButton.frame.contains(point) {
            return eyeButton
        }
        
        return super.hitTest(point, with: event)
    }
}
