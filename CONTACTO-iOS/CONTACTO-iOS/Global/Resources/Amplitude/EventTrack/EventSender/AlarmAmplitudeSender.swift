//
//  AlarmAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/14/25.
//

import Foundation

protocol AlarmAmplitudeSender: EventAmplitudeSender{
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

extension AlarmAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.PUSH, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.PUSH, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
