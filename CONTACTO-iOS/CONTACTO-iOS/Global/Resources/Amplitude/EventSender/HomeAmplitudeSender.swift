//
//  HomeAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/3/25.
//

import Foundation

public protocol HomeAmplitudeSender: EventAmplitudeSender {
    func sendAmpliLog(eventName: EventName)

    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension HomeAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.HOME, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.HOME, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
