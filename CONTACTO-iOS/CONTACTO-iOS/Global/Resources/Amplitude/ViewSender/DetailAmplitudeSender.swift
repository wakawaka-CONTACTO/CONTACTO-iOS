//
//  DetailAmplitudeSender.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

public protocol DetailAmplitudeSender {
    func sendAmpliLog(eventName: EventName)
    func sendAmpliLog(eventName: EventName, properties: [String: Any])
}

public extension DetailAmplitudeSender {
    
}
