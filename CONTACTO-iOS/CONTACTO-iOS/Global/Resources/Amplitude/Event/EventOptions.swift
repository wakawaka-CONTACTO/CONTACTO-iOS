//
//  EventOptions.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/25/25.
//

import Foundation

public struct EventOptions {
    public let deviceId: String?
    public let userId: String?
    
    public init(deviceId: String? = nil, userId: String? = nil){
        self.deviceId = deviceId
        self.userId = userId
    }
}
