//
//  EventName.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/26/25.
//

import Foundation

public struct EventInfo {
    let eventView: EventView
    let eventName: EventName
    let trigger: String
    
    init(event: EventView, eventName: EventName){
        self.eventView = event
        self.eventName = eventName
        self.trigger = eventName.trigger
    }
}
