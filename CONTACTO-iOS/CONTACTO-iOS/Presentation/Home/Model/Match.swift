//
//  Match.swift
//  CONTACTO-iOS
//
//  Created by 하나 on 3/2/25.
//

import Foundation

struct Match: Codable {
    let myId: Int
    let myLabel: String
    let myImageURL: String
    let yourId: Int
    let yourLabel: String
    let yourImageURL: String
    let chatRoomId: Int
}
