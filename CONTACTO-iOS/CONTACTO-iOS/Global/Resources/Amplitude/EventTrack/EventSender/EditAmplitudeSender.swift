//
//  EditAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/7/25.
//

import Foundation

protocol EditAmplitudeSender: EventAmplitudeSender{
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

extension EditAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.EDIT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.EDIT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
