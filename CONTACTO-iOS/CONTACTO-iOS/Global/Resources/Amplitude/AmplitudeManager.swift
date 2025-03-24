//
//  AmplitudeManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/24/25.
//

import Foundation
import AmplitudeSwift

public struct AmplitudeManager{
    static public let amplitude = Amplitude(configuration: Configuration(
        apiKey: Config.amplitudeApiKey,
        defaultTracking: DefaultTrackingOptions(
            sessions: true
        )
    ))
    
    private init(){}
}

public extension Amplitude {
    func track(eventType: AmplitudeEventType, eventProperties: [String: Any]? = nil) {
        let eventType: String = eventType.rawValue
        
        AmplitudeManager.amplitude.track(eventType: eventType, eventProperties: eventProperties, options: nil)
    }
}
