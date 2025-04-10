//
//  InfoAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/8/25.
//

import Foundation

public protocol InfoAmplitudeSender: EventAmplitudeSender {
    func sendAmpliLog(eventName: EventName)

    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}


public extension InfoAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.INFO, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.INFO, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
