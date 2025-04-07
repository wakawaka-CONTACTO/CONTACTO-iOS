//
//  AmplitudeManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/2/25.
//

import Foundation
import AmplitudeSwift

public struct AmplitudeManager{
    static public var amplitude: Amplitude!
    
    private init(){ }
}

extension Amplitude {
    func track(eventInfo: EventInfo) {
        let eventType = eventInfo.eventName.rawValue
        let properties: [String: Any] = [
            "view": eventInfo.eventView.rawValue,
            "trigger": eventInfo.trigger
        ]
        print("[LOG] amplitude track \(properties)")
        AmplitudeManager.amplitude.track(eventType: eventType, eventProperties: properties)
    }
    
    func track(eventInfo: EventInfo, properties: [String: Any]? = nil) {
        var eventProps: [String: Any] = [
            "view": eventInfo.eventView.rawValue,
            "trigger": eventInfo.trigger
        ]
        
        if let additionalProps = properties {
            for (key, value) in additionalProps {
                eventProps[key] = value
            }
        }
        
        AmplitudeManager.amplitude.track(
            eventType: eventInfo.eventName.rawValue,
            eventProperties: eventProps
        )
    }
}
