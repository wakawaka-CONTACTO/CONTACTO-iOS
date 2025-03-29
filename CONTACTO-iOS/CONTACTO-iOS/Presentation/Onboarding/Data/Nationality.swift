//
//  Nationality.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/13/25.
//

import Foundation

enum Nationalities: String, CaseIterable {
    case NONE
    case UK, CN, JP, US, KR, FR, DE, NL, OTHER
    
    var displayName: String {
        switch self {
        case .NONE:  return "SELECT YOUR NATIONALITY"
        case .UK:    return "UNITED KINGDOM"
        case .CN:    return "CHINA"
        case .JP:    return "JAPAN"
        case .US:    return "UNITED STATES"
        case .KR:    return "KOREA"
        case .FR:    return "FRANCE"
        case .DE:    return "GERMANY"
        case .NL:    return "NETHERLANDS"
        case .OTHER: return "OTHER"
        }
    }
}
