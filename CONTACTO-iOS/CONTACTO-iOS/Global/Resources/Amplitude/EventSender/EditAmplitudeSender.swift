//
//  EditAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/7/25.
//

import Foundation

//public protocol EditAmplitudeSender: EventAmplitudeSender{
//    func sendAmpliLog(eventName: EventName)
//    func sendAmpliLog(eventName: EventName, properties: [String: Any])
//}

public class EditAmplitudeSender: EventAmplitudeSender{
    public func sendAmpliLog(eventName: EventName){
        let info = EventInfo(event: EventView.EDIT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info)
    }

    public func sendAmpliLog(eventName: EventName, properties: [String: Any]){
        let info = EventInfo(event: EventView.EDIT, eventName: eventName)
        
        AmplitudeManager.amplitude.track(eventInfo: info, properties: properties)
    }
}
