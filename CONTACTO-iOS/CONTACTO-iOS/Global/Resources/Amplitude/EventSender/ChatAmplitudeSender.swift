//
//  ChatAmpllitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/8/25.
//

import Foundation

public protocol ChatAmplitudeSender: EventAmplitudeSender{
    
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension ChatAmplitudeSender{
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.CHAT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }
    
    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.CHAT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
