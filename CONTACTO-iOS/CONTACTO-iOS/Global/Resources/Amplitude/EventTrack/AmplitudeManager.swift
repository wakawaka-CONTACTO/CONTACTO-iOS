//
//  AmplitudeManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/2/25.
//

import Foundation
import AmplitudeSwift

public struct AmplitudeManager{
    static var amplitude: Amplitude!
    
    private init(){ }
}

extension Amplitude {
    func track(eventInfo: EventInfo) {
        let eventType = eventInfo.eventName.rawValue
        let properties: [String: Any] = [
            "view": eventInfo.eventView.rawValue,
            "trigger": eventInfo.trigger
        ]
#if DEBUG
        print("[LOG] amplitude track \(properties)")
#endif
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
#if DEBUG
        print("[LOG] amplitude track \(eventProps)")
#endif
        AmplitudeManager.amplitude.track(
            eventType: eventInfo.eventName.rawValue,
            eventProperties: eventProps
        )
    }
}

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}
