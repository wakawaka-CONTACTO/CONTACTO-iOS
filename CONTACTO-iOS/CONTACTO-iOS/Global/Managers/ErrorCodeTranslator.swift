//
//  ErrorCodeTranslator.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/22/25.
//

import Foundation

final class ErrorCodeTranslator {
    static let shared = ErrorCodeTranslator()
    
    private init() {}
    
    enum ErrorCode: String {
        // Conflict (409)
        case duplicateResource = "e4090"
        case duplicateUser = "e4091"
        case duplicateNickname = "e4092"
        case duplicateEmail = "e4093"
        
        // Not Found (404)
        case notFoundResource = "e4040"
        case notFoundUser = "e4041"
        case notFoundEmail = "e4042"
        
        // Bad Request (400)
        case invalidFormat = "e4000"
        case invalidEmail = "e4001"
        case invalidPassword = "e4002"
        
        // Unauthorized (401)
        case unauthorized = "e4010"
        case invalidToken = "e4011"
        case expiredToken = "e4012"
        
        // Forbidden (403)
        case forbidden = "e4030"
        case insufficientPermission = "e4031"
        
        // Internal Server Error (500)
        case serverError = "e5000"
        case databaseError = "e5001"
    }
    
    func translate(_ errorCode: String) -> String {
        guard let code = ErrorCode(rawValue: errorCode) else {
            return "An unexpected error occurred."
        }
        
        switch code {
        // Conflict (409)
        case .duplicateResource:
            return "The resource already exists."
        case .duplicateUser:
            return "This user already exists."
        case .duplicateNickname:
            return "This nickname is already taken."
        case .duplicateEmail:
            return "This email is already registered."
            
        // Not Found (404)
        case .notFoundResource:
            return "The requested resource was not found."
        case .notFoundUser:
            return "User not found."
        case .notFoundEmail:
            return "Email not found."
            
        // Bad Request (400)
        case .invalidFormat:
            return "Invalid format."
        case .invalidEmail:
            return "Invalid email format."
        case .invalidPassword:
            return "Invalid password format."
            
        // Unauthorized (401)
        case .unauthorized:
            return "Unauthorized access."
        case .invalidToken:
            return "Invalid authentication token."
        case .expiredToken:
            return "Authentication token has expired."
            
        // Forbidden (403)
        case .forbidden:
            return "Access forbidden."
        case .insufficientPermission:
            return "Insufficient permissions."
            
        // Internal Server Error (500)
        case .serverError:
            return "Internal server error occurred."
        case .databaseError:
            return "Database error occurred."
        }
    }
}
