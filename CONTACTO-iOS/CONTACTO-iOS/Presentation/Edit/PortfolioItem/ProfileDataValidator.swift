//
//  ProfileValidator.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/19/25.
//

import Foundation

struct ProfileDataValidator {
    static func validateName(_ name: String?) -> ValidationResult {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return ValidationResult(isValid: false, message: "Your name field is empty.")
        }
        let nameRegex = "^[a-zA-Z0-9가-힣]{2,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !predicate.evaluate(with: name) {
            return ValidationResult(isValid: false, message: "The name can only be 2 to 20 characters in English, numbers, and Korean.")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validateWebsite(_ website: String?) -> ValidationResult {
        guard let website = website?.trimmingCharacters(in: .whitespacesAndNewlines), !website.isEmpty else {
            // 웹사이트는 선택사항인 경우 유효함
            return ValidationResult(isValid: true, message: nil)
        }
        if !(website.hasPrefix("http://") || website.hasPrefix("https://")) {
            return ValidationResult(isValid: false, message: "website URL should start with http:// or https://")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validatePurpose(_ purposes: [Int]?) -> ValidationResult {
        if purposes?.isEmpty ?? true {
            return ValidationResult(isValid: false, message: "You should select Purpose.")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validateTalent(_ talents: [UserTalent]?) -> ValidationResult {
        if talents?.isEmpty ?? true {
            return ValidationResult(isValid: false, message: "You should select Talent.")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validatePortfolio(_ portfolioItemsCount: Int) -> ValidationResult {
        if portfolioItemsCount <= 0 {
            return ValidationResult(isValid: false, message: "You should select Portfolio.")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validateNationality(_ nationality: Nationalities) -> ValidationResult{
        if nationality == Nationalities.NONE {
            return ValidationResult(isValid: false, message: "You should select Natioinality.")
        }
        return ValidationResult(isValid: true, message: nil)
    }
    
    static func validateProfile(name: String?, website: String?, purposes: [Int]?, talents: [UserTalent]?,
                                nationality: Nationalities, portfolioItemsCount: Int) -> ValidationResult {
        let nameValidation = validateName(name)
        if !nameValidation.isValid { return nameValidation }
        
        let websiteValidation = validateWebsite(website)
        if !websiteValidation.isValid { return websiteValidation }
        
        let purposeValidation = validatePurpose(purposes)
        if !purposeValidation.isValid { return purposeValidation }
        
        let talentValidation = validateTalent(talents)
        if !talentValidation.isValid { return talentValidation }
        
        let portfolioValidation = validatePortfolio(portfolioItemsCount)
        if !portfolioValidation.isValid { return portfolioValidation }
        
        let nationalityValidation = validateNationality(nationality)
        if !nationalityValidation.isValid { return nationalityValidation }
        
        return ValidationResult(isValid: true, message: nil)
    }
}
