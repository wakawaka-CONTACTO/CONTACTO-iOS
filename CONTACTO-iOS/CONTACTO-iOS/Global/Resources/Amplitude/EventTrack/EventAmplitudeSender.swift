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
