//
//  OnboadingAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

public protocol OnboadingAmplitudeSender{}

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
