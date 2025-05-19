//
//  KeychainHandler.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

import SwiftKeychainWrapper

struct Credentials {
    var tokenName: String
    var tokenContent: String
}

struct KeychainHandler {
    static var shared = KeychainHandler()
    
    private let keychain = KeychainWrapper(serviceName: "CONTACTO", accessGroup: "com.CONTACTO.iOS.keychainGroup")
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userIDKey = "userID"
    private let userNameKey = "userName"
    
    var accessToken: String {
        get {
            return KeychainWrapper.standard.string(forKey: accessTokenKey) ?? ""
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: accessTokenKey)
        }
    }
    
    var refreshToken: String {
        get {
            return KeychainWrapper.standard.string(forKey: refreshTokenKey) ?? ""
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: refreshTokenKey)
        }
    }
    
    var userID: String {
        get {
            return KeychainWrapper.standard.string(forKey: userIDKey) ?? "UNKNOWN"
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: userIDKey)
        }
    }
    
    var userName: String {
        get {
            return KeychainWrapper.standard.string(forKey: userNameKey) ?? "User"
        }
        set {
            KeychainWrapper.standard.set(newValue, forKey: userNameKey)
        }
    }
    
    mutating func logout() {
        accessToken = ""
        refreshToken = ""
        
        KeychainWrapper.standard.removeObject(forKey: userIDKey)
        KeychainWrapper.standard.removeObject(forKey: accessTokenKey)
        KeychainWrapper.standard.removeObject(forKey: refreshTokenKey)
    }
    
    mutating func deleteID() {
        accessToken = ""
        refreshToken = ""
        
        KeychainWrapper.standard.removeObject(forKey: userIDKey)
        KeychainWrapper.standard.removeObject(forKey: accessTokenKey)
        KeychainWrapper.standard.removeObject(forKey: refreshTokenKey)
    }
}
