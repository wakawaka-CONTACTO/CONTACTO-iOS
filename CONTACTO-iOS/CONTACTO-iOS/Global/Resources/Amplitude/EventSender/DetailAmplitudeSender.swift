//
//  DetailAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/4/25.
//

import Foundation

public protocol DetailAmplitudeSender: EventAmplitudeSender{
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension DetailAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.DETAIL, eventName: eventName)
        let userId = "Amplitude Test Account"
        AmplitudeManager.amplitude.setUserId(userId: userId)
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.DETAIL, eventName: eventName)
        let userId = "Amplitude Test Account"
        AmplitudeManager.amplitude.setUserId(userId: userId)
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
