//
//  HomeAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/3/25.
//

import Foundation

class HomeAmplitudeSender: EventAmplitudeSender {
    public func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.HOME, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    public func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.HOME, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
