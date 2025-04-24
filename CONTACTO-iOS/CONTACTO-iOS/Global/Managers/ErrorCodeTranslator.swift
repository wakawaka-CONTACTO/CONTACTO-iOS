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
    
    private let errorMessages: [String: String] = [
        // Bad Request (400)
        "e4000": "Invalid request.",
        "e4001": "Invalid platform type.",
        "e4002": "Invalid login credentials.",
        "e4003": "Unsupported image format.",
        "e4004": "Unsupported image size.",
        "e4005": "Invalid image URL.",
        "e4006": "Invalid password format.",
        "e4007": "Invalid nickname format.",
        "e4008": "Invalid email format.",
        "e4009": "Date course images can have up to 10 images.",
        "e40010": "Cannot like your own profile.",
        "e40011": "Cannot block your own profile.",
        "e40012": "Cannot report your own profile.",
        "e4102": "Invalid field value.",
        "e4103": "Invalid input field.",
        "e4104": "Failed to send Discord signup notification.",
        "e4105": "Failed to edit profile image.",
        "e4106": "Failed to connect to socket.",
        "e4107": "Nationality information is not provided. Please enter a valid nationality.",
        "e4108": "Failed to edit portfolio image.",
        
        // Unauthorized (401)
        "e4010": "You don't have permission to access this resource.",
        "e4011": "Invalid access token value.",
        "e4012": "Your access token has expired. Please request a new one.",
        "e4013": "Token subject is not a numeric string.",
        "e4014": "Unsupported token type.",
        "e4015": "Malformed token structure.",
        "e4016": "Invalid token signature.",
        "e4017": "Kakao internal server error occurred.",
        "e4018": "Invalid Kakao access token format.",
        "e4019": "Invalid user information in token.",
        "e4020": "Password does not match.",
        "e4022": "Email login is required for this account.",
        "e4023": "Invalid user password value.",
        "e40114": "Invalid refresh token.",
        "e40115": "Your refresh token has expired. Please log in again.",
        "e40116": "Invalid Kakao communication access.",
        "e40117": "Failed to unlink Kakao account.",
        "e40118": "Invalid Apple token communication access.",
        "e40119": "Invalid date type search.",
        "e40120": "Invalid point transaction type search.",
        "e40121": "Invalid region input.",
        
        // Forbidden (403)
        "e4030": "Access forbidden.",
        "e4031": "Failed to join chat room.",
        "e4032": "No access permission for chat room.",
        "e4033": "Failed to send message.",
        "e4034": "No access permission for profile.",
        "e4035": "No permission to update profile.",
        "e4036": "No access permission for portfolio.",
        
        // Not Found (404)
        "e4040": "Target not found.",
        "e4041": "Token type not found.",
        "e4042": "User not found.",
        "e4043": "Chat room not found.",
        "e4044": "Portfolio not found.",
        "e4045": "Like information not found.",
        "e4046": "User purpose not found.",
        "e4047": "User talent not found.",
        "e4048": "Image not found.",
        
        // Method Not Allowed (405)
        "e4050": "Invalid HTTP method request.",
        
        // Conflict (409)
        "e4090": "Resource already exists.",
        "e4091": "User already exists.",
        "e4092": "Nickname already exists.",
        "e4093": "Email already exists.",
        
        // Internal Server Error (500)
        "e5000": "Internal server error occurred.",
        "e5001": "Failed to create course.",
        "e5002": "Failed to create point.",
        "e5003": "Failed to connect to Redis.",
        "e5004": "Discord log content does not exist.",
        "e5005": "Service is unavailable.",
        "e5006": "YAML configuration failed to load.",
        "e5007": "Failed to generate portfolio ID."
    ]
    
    func translate(_ errorCode: String) -> String {
        return errorMessages[errorCode] ?? "An unexpected error occurred."
    }
}
