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
        // Bad Request (400)
        case badRequest = "e4000"
        case invalidPlatformType = "e4001"
        case invalidUserCredentials = "e4002"
        case invalidImageType = "e4003"
        case invalidImageSize = "e4004"
        case wrongImageUrl = "e4005"
        case invalidPasswordFormat = "e4006"
        case invalidNicknameFormat = "e4007"
        case invalidEmailFormat = "e4008"
        case wrongImageListSize = "e4009"
        case invalidUserLike = "e40010"
        case invalidUserBlock = "e40011"
        case invalidUserReport = "e40012"
        case invalidTypeValue = "e4102"
        case invalidInputValue = "e4103"
        case invalidDiscordSignupMessage = "e4104"
        case invalidImageEdit = "e4105"
        case socketConnectedFailed = "e4106"
        case nationalityNotProvided = "e4107"
        case invalidPortfolioEdit = "e4108"
        
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
        case chatRoomJoinFailed = "e4031"
        case chatRoomAccessDenied = "e4032"
        case chatMessageSendFailed = "e4033"
        case userProfileAccessDenied = "e4034"
        case userUpdateFailed = "e4035"
        case portfolioAccessDenied = "e4036"
        
        // Not Found (404)
        case entityNotFound = "e4040"
        case tokenTypeNotFound = "e4041"
        case userNotFound = "e4042"
        case chatroomNotFound = "e4043"
        case portfolioNotFound = "e4044"
        case userLikeNotFound = "e4045"
        case userPurposeNotFound = "e4046"
        case userTalentNotFound = "e4047"
        case imageNotFound = "e4048"
        
        // Method Not Allowed (405)
        case methodNotAllowed = "e4050"
        
        // Conflict (409)
        case conflict = "e4090"
        case duplicateUser = "e4091"
        case duplicateNickname = "e4092"
        case duplicateEmail = "e4093"
        
        // Internal Server Error (500)
        case serverError = "e5000"
        case courseCreateError = "e5001"
        case pointCreateError = "e5002"
        case redisConnectionError = "e5003"
        case discordError = "e5004"
        case serviceUnavailable = "e5005"
        case invalidConfiguration = "e5006"
        case portfolioIdGenerationFailed = "e5007"
    }
    
    func translate(_ errorCode: String) -> String {
        guard let code = ErrorCode(rawValue: errorCode) else {
            return "An unexpected error occurred."
        }
        
        switch code {
        // Bad Request (400)
        case .badRequest:
            return "Invalid request."
        case .invalidPlatformType:
            return "Invalid platform type."
        case .invalidUserCredentials:
            return "Invalid login credentials."
        case .invalidImageType:
            return "Unsupported image format."
        case .invalidImageSize:
            return "Unsupported image size."
        case .wrongImageUrl:
            return "Invalid image URL."
        case .invalidPasswordFormat:
            return "Invalid password format."
        case .invalidNicknameFormat:
            return "Invalid nickname format."
        case .invalidEmailFormat:
            return "Invalid email format."
        case .wrongImageListSize:
            return "Date course images can have up to 10 images."
        case .invalidUserLike:
            return "Cannot like your own profile."
        case .invalidUserBlock:
            return "Cannot block your own profile."
        case .invalidUserReport:
            return "Cannot report your own profile."
        case .invalidTypeValue:
            return "Invalid field value."
        case .invalidInputValue:
            return "Invalid input field."
        case .invalidDiscordSignupMessage:
            return "Failed to send Discord signup notification."
        case .invalidImageEdit:
            return "Failed to edit profile image."
        case .socketConnectedFailed:
            return "Failed to connect to socket."
        case .nationalityNotProvided:
            return "Nationality information is not provided. Please enter a valid nationality."
        case .invalidPortfolioEdit:
            return "Failed to edit portfolio image."
            
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
        case .chatRoomJoinFailed:
            return "Failed to join chat room."
        case .chatRoomAccessDenied:
            return "No access permission for chat room."
        case .chatMessageSendFailed:
            return "Failed to send message."
        case .userProfileAccessDenied:
            return "No access permission for profile."
        case .userUpdateFailed:
            return "No permission to update profile."
        case .portfolioAccessDenied:
            return "No access permission for portfolio."
            
        // Not Found (404)
        case .entityNotFound:
            return "Target not found."
        case .tokenTypeNotFound:
            return "Token type not found."
        case .userNotFound:
            return "User not found."
        case .chatroomNotFound:
            return "Chat room not found."
        case .portfolioNotFound:
            return "Portfolio not found."
        case .userLikeNotFound:
            return "Like information not found."
        case .userPurposeNotFound:
            return "User purpose not found."
        case .userTalentNotFound:
            return "User talent not found."
        case .imageNotFound:
            return "Image not found."
            
        // Method Not Allowed (405)
        case .methodNotAllowed:
            return "Invalid HTTP method request."
            
        // Conflict (409)
        case .conflict:
            return "Resource already exists."
        case .duplicateUser:
            return "User already exists."
        case .duplicateNickname:
            return "Nickname already exists."
        case .duplicateEmail:
            return "Email already exists."
            
        // Internal Server Error (500)
        case .serverError:
            return "Internal server error occurred."
        case .courseCreateError:
            return "Failed to create course."
        case .pointCreateError:
            return "Failed to create point."
        case .redisConnectionError:
            return "Failed to connect to Redis."
        case .discordError:
            return "Discord log content does not exist."
        case .serviceUnavailable:
            return "Service is unavailable."
        case .invalidConfiguration:
            return "YAML configuration failed to load."
        case .portfolioIdGenerationFailed:
            return "Failed to generate portfolio ID."
        }
    }
}
