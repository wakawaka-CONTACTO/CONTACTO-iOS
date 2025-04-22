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
        case invalidAccessTokenValue = "e4011"
        case expiredAccessToken = "e4012"
        case tokenSubjectNotNumeric = "e4013"
        case unsupportedTokenType = "e4014"
        case malformedToken = "e4015"
        case invalidSignatureToken = "e4016"
        case kakaoInternalError = "e4017"
        case invalidKakaoToken = "e4018"
        case invalidTokenUser = "e4019"
        case passwordMismatch = "e4020"
        case emailLoginRequired = "e4022"
        case invalidUserPassword = "e4023"
        case invalidRefreshTokenValue = "e40114"
        case expiredRefreshToken = "e40115"
        case invalidKakaoAccess = "e40116"
        case unlinkWithKakaoUnauthorized = "e40117"
        case invalidAppleTokenAccess = "e40118"
        case invalidDateGetType = "e40119"
        case invalidTransactionType = "e40120"
        case invalidRegionType = "e40121"
        
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
            return "You don't have permission to access this resource."
        case .invalidAccessTokenValue:
            return "Invalid access token value."
        case .expiredAccessToken:
            return "Your access token has expired. Please request a new one."
        case .tokenSubjectNotNumeric:
            return "Token subject is not a numeric string."
        case .unsupportedTokenType:
            return "Unsupported token type."
        case .malformedToken:
            return "Malformed token structure."
        case .invalidSignatureToken:
            return "Invalid token signature."
        case .kakaoInternalError:
            return "Kakao internal server error occurred."
        case .invalidKakaoToken:
            return "Invalid Kakao access token format."
        case .invalidTokenUser:
            return "Invalid user information in token."
        case .passwordMismatch:
            return "Password does not match."
        case .emailLoginRequired:
            return "Email login is required for this account."
        case .invalidUserPassword:
            return "Invalid user password value."
        case .invalidRefreshTokenValue:
            return "Invalid refresh token."
        case .expiredRefreshToken:
            return "Your refresh token has expired. Please log in again."
        case .invalidKakaoAccess:
            return "Invalid Kakao communication access."
        case .unlinkWithKakaoUnauthorized:
            return "Failed to unlink Kakao account."
        case .invalidAppleTokenAccess:
            return "Invalid Apple token communication access."
        case .invalidDateGetType:
            return "Invalid date type search."
        case .invalidTransactionType:
            return "Invalid point transaction type search."
        case .invalidRegionType:
            return "Invalid region input."
            
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
