//
//  Config.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

enum Config {
    enum Keys {
        enum Plist {
            static let baseURL = "BASE_URL"
            static let chatBaseURL = "CHAT_BASE_URL"
            static let amplitudeApiKey = "AMPLITUDE_API_KEY"
            static let amplitudeSecretKey = "AMPLITUDE_SECRET_KEY"
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
}

extension Config {
    static let baseURL: String = {
        guard let key = Config.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Base URL is not set in plist for this configuration.")
        }
        return key
    }()
    
    static let chatBaseURL: String = {
        guard let key = Config.infoDictionary[Keys.Plist.chatBaseURL] as? String else {
            fatalError("CHAT BASE URL is not set in plist for this configuration.")
        }
        return key
    }()
    
    static let amplitudeApiKey: String = {
        guard let key = Config.infoDictionary[Keys.Plist.amplitudeApiKey] as? String else {
            fatalError("amplitudeApiKey is not set in plist for this configuration.")
        }
        return key
    }()
    
    static let amplitudeSecretKey: String = {
        guard let key = Config.infoDictionary[Keys.Plist.amplitudeSecretKey] as? String else {
            fatalError("amplitudeSecretKey is not set in plist for this configuration.")
        }
        return key
    }()
}
