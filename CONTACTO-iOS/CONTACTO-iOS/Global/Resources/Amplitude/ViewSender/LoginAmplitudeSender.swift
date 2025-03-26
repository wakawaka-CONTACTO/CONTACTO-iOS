//
//  LoginAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

public protocol LoginAmplitudeSender {
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension LoginAmplitudeSender {
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.LOGIN, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }
    
    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.LOGIN, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
