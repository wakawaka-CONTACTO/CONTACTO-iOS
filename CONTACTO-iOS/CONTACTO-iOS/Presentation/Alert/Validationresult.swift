//
//  Validationresult.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/14/25.
//

struct ValidationResult {
    let isValid: Bool
    let message: String?
    
    func isValidValue() -> Bool {
        return isValid
    }

}
