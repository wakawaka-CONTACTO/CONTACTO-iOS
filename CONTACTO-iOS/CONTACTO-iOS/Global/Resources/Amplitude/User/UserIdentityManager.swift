//
//  UserPropertiesManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/9/25.
//

import Foundation
import AmplitudeSwift

public struct UserIdentityManager{
    
    static func setUserId(){
        let userId = "[\(KeychainHandler.shared.userID)] \(KeychainHandler.shared.userName)"
        AmplitudeManager.amplitude.setUserId(userId: userId)
    }
    
    static func setUserId(userId: String, status: String) {
        let key = "[\(status)] \(userId)"
        AmplitudeManager.amplitude.setUserId(userId: key)
    }
    
    static func syncUserInfo() {
        let identity = Identify()
        identity.set(property: "user_email", value: UserInfo.shared.email)
        identity.set(property: "user_name", value: UserInfo.shared.name)
        identity.set(property: "user_description", value: UserInfo.shared.description)
        identity.set(property: "user_insta", value: UserInfo.shared.instagramId)
        identity.set(property: "user_web", value: UserInfo.shared.webUrl)
        identity.set(property: "user_nationality", value: UserInfo.shared.nationality)
        
        let lastUsed = ISO8601DateFormatter.shared.string(from: Date())
        identity.set(property: "user_last_use_date", value: lastUsed)
        
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func myDetailProperty(data: MyDetailResponseDTO){
        let identity = Identify()
        let key = "\(data.id) - \(data.username)"
        AmplitudeManager.amplitude.setUserId(userId: key)
        
        identity.set(property: "user_email", value: data.email)
        identity.set(property: "user_name", value: data.username)
        identity.set(property: "user_description", value: data.description)
        identity.set(property: "user_insta", value: data.instagramId)
        identity.set(property: "user_web", value: data.webUrl)
        identity.set(property: "user_nationality", value: data.nationality)

        identity.set(property: "user_talent", value: data.userTalents.map { $0.talentType })
        identity.set(property: "user_purpose", value: data.userPurposes.map { ProfilePurpose(rawValue: $0)?.displayName ?? "" })
        identity.set(property: "user_portfolio_count", value: data.userPortfolio?.portfolioImageUrl.count)
        
        let lastUsed = ISO8601DateFormatter.shared.string(from: Date())
        identity.set(property: "user_last_use_date", value: lastUsed)
        
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func updateDetailProperty(data: EditRequestBodyDTO){
        let identity = Identify()
        identity.set(property: "user_email", value: data.email)
        identity.set(property: "user_name", value: data.username)
        identity.set(property: "user_description", value: data.description)
        identity.set(property: "user_insta", value: data.instagramId)
        identity.set(property: "user_web", value: data.webUrl)
        identity.set(property: "user_nationality", value: data.nationality)

        identity.set(property: "user_talent", value: data.userTalents.map { Talent(rawValue: $0)?.info.displayName ?? ""})
        identity.set(property: "user_purpose", value: data.userPurposes.map { ProfilePurpose(rawValue: $0)?.displayName ?? "" })
        identity.set(property: "user_portfolio_count", value: (data.existedImageUrl?.count ?? 0) + (data.newPortfolioImages?.count ?? 0))
        
        let lastUsed = ISO8601DateFormatter.shared.string(from: Date())
        identity.set(property: "user_last_use_date", value: lastUsed)
        
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func homeYes(){
        let identity = Identify()
        identity.add(property: "user_home_yes", value: 1)
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func homeNo(){
        let identity = Identify()
        identity.add(property: "user_home_no", value: 1)
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func chatroom(){
        let identity = Identify()
        identity.add(property: "user_chatroom_count", value: 1)
        AmplitudeManager.amplitude.identify(identify: identity)
    }
    
    static func agreePushNotification(isAgree: Bool){
        let identity = Identify()
        identity.set(property: "user_pushnotification", value: isAgree)
        AmplitudeManager.amplitude.identify(identify: identity)
    }
}
