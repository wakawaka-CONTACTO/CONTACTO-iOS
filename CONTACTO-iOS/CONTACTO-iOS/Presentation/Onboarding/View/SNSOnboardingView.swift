//
//  SNSOnboardingView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class SNSOnboardingView: BaseView {
    
    private let topBackgroundView = UIView()
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    
    private let instaLabel = UILabel()
    let instaTextField = BaseTextField()
    private let instaAtLabel = UILabel()
    
    private let websiteLabel = UILabel()
    let websiteTextField = UITextField()

    private let nationalityLabel = UILabel()
    let nationalityTextField = BaseTextField()
    private let nationalityPicker = UIPickerView()
    private let nationalities: [Nationalities] = Nationalities.allCases
    var selectedNationality: Nationalities = .NONE

    let nextButton = OnboardingNextButton(count: 4)
    
    override func setStyle() {
        self.backgroundColor = .ctmainpink
        
        topBackgroundView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = UIImage(resource: .onboardingTop)
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.text = StringLiterals.Onboarding.SNS.title
            $0.textColor = .ctblack
            $0.font = .fontContacto(.title1)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        instaLabel.do {
            $0.text = "\(StringLiterals.Onboarding.SNS.instagram)  \(StringLiterals.Onboarding.SNS.required)"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
            $0.asFont(targetString: "  \(StringLiterals.Onboarding.SNS.required)", font: .fontContacto(.caption3))
        }
        
        instaTextField.do {
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctwhite
            $0.textColor = .ctblack
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.addPadding(left: 27)
            $0.autocapitalizationType = .none
            $0.keyboardType = .asciiCapable
        }
        
        instaAtLabel.do {
            $0.text = "@"
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
        }
        
        websiteLabel.do {
            $0.text = StringLiterals.Onboarding.SNS.website
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
        }
        
        websiteTextField.do {
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Onboarding.SNS.example, forColor: .ctgray2)
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctwhite
            $0.textColor = .ctblack
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.autocapitalizationType = .none
            $0.addPadding(left: 10)
            $0.text = "https://"
            $0.delegate = self
        }
        
        nationalityLabel.do {
            $0.text = "\(StringLiterals.Onboarding.Nationality.title)  \(StringLiterals.Onboarding.SNS.required)"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
            $0.asFont(targetString: "  \(StringLiterals.Onboarding.SNS.required)", font: .fontContacto(.caption3))
        }
        
        nationalityTextField.do {
            $0.placeholder = Nationalities.NONE.displayName
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.addPadding(left: 10)
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .ctwhite
            $0.textColor = .ctblack
            $0.inputView = nationalityPicker
            $0.delegate = self
        }
        
        nationalityPicker.delegate = self
        nationalityPicker.dataSource = self
    }
    
    override func setLayout() {
        addSubviews(topBackgroundView,
                    topImageView,
                    titleLabel,
                    instaLabel,
                    instaTextField,
                    websiteLabel,
                    websiteTextField,
                    nationalityLabel,
                    nationalityTextField,
                    nextButton)
        
        instaTextField.addSubviews(instaAtLabel)
        
        topBackgroundView.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.height.equalTo(145.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(26.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(18.adjustedWidth)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topImageView.snp.bottom).offset(41.adjustedHeight)
            $0.centerX.equalToSuperview()
        }
        
        instaLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50.adjustedHeight)
            $0.leading.equalToSuperview().inset(16.adjustedWidth)
        }
        
        instaTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjustedWidth)
            $0.top.equalTo(instaLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        instaAtLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
        
        websiteLabel.snp.makeConstraints {
            $0.top.equalTo(instaTextField.snp.bottom).offset(25.adjustedHeight)
            $0.leading.equalTo(instaLabel)
        }
        
        websiteTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(instaTextField)
            $0.top.equalTo(websiteLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        nationalityLabel.snp.makeConstraints {
            $0.top.equalTo(websiteTextField.snp.bottom).offset(25.adjustedHeight)
            $0.leading.equalTo(websiteLabel)
        }
        
        nationalityTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(websiteTextField)
            $0.top.equalTo(nationalityLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(55.adjustedHeight)
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SNSOnboardingView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
  
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nationalities.count
    }
  
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return nationalities[row].displayName
    }
  
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNationality = nationalities[row]
        nationalityTextField.text = nationalities[row].displayName
        nationalityTextField.resignFirstResponder()
        
        let isInstaFilled = !(instaTextField.text?.isEmpty ?? true)
        nextButton.isEnabled = selectedNationality != .NONE && isInstaFilled
    }
}

extension SNSOnboardingView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nationalityTextField {
            nextButton.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nationalityTextField {
            nextButton.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == websiteTextField {
            // 이모지 체크
            for scalar in string.unicodeScalars {
                switch scalar.value {
                case 0x1F600...0x1F64F, // Emoticons
                     0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                     0x1F680...0x1F6FF, // Transport and Map
                     0x1F1E6...0x1F1FF, // Regional country flags
                     0x2600...0x26FF,   // Misc symbols
                     0x2700...0x27BF,   // Dingbats
                     0xFE00...0xFE0F,   // Variation Selectors
                     0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                     0x1F018...0x1F270: // Various asian characters
                    return false
                default:
                    continue
                }
            }
            return true
        }
        return true
    }
}
