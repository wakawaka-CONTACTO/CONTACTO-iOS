//
//  EventAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/3/25.
//

import Foundation

public protocol EventAmplitudeSender {
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public class extensionAmplitudeSender: EventAmplitudeSender {
    let eventView: EventView

    init(eventView: EventView) {
        self.eventView = eventView
    }
    
    public func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: eventView, eventName: eventName)

        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    public func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: eventView, eventName: eventName)

        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
