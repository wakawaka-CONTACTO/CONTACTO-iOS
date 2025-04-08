//
//  UserAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import AmplitudeSwift
import Foundation

public final class AmplitudeUserPropertySender {

    static func setUserProperties(user: UserPropertiesInfo) {
        let identify = Identify()
        
        let userId = "\(KeychainHandler.shared.userID) - \(KeychainHandler.shared.userName)"
        AmplitudeManager.amplitude.setUserId(userId: userId)
        // String
        identify.set(property: "user_name", value: user.name)
        identify.set(property: "user_email", value: user.email)
        identify.set(property: "user_description", value: user.description)
        identify.set(property: "user_insta", value: user.instagramId)
        identify.set(property: "user_web", value: user.webUrl)

        // Int
        identify.set(property: "user_portfolio_count", value: user.portfolioCount)
        identify.set(property: "user_home_yes", value: user.homeYesCount)
        identify.set(property: "user_home_no", value: user.homeNoCount)
        identify.set(property: "user_chatroom_count", value: user.chatroomCount)

        // Array
        identify.set(property: "user_talent", value: user.talents)
        identify.set(property: "user_purpose", value: user.purposes)

        // Bool
        identify.set(property: "user_pushnotification", value: user.pushNotificationConsent)
        let isoFormatter = ISO8601DateFormatter()
        let lastUsed = isoFormatter.string(from: user.lastUseDate)
        identify.set(property: "user_last_use_date", value: lastUsed)

        AmplitudeManager.amplitude.identify(identify: identify)
    }
}
