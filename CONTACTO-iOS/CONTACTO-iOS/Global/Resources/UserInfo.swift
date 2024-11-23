//
//  UserInfo.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/24/24.
//

import Foundation

final class UserInfo {
    static let shared = UserInfo()
    
    var email: String = ""
    var password: String = ""
}
