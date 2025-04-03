//
//  OnbodingAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/3/25.
//

import Foundation
class OnbodingAmplitudeSender: EventAmplitudeSender {
    
    public func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.ONBOARDING, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    public func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.ONBOARDING, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}


public protocol OnboadingAmplitudeSender: EventAmplitudeSender{
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension OnboadingAmplitudeSender{
    func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.ONBOARDING, eventName: eventName)

        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.ONBOARDING, eventName: eventName)

        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
