//
//  AmplitudeEvent.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/25/25.
//

public class Event {
    public let eventType: String
    public let eventProperties: [String:Any]?
    public let options: EventOptions?
    
    init(eventType: String, eventProperties: [String:Any?]? , options: EventOptions?){
        self.eventType = eventType
        self.eventProperties = eventProperties?.compactMapValues { $0 }
        self.options = options
    }
}
