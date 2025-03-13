//
//  Nationality.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/13/25.
//

import Foundation

enum Nationality: String, CaseIterable {
    case UK, CN, JP, US, KR, FR, DE, NL, OTHER
    
    var displayName: String {
        switch self {
        case .UK:    return "United Kingdom"
        case .CN:    return "China"
        case .JP:    return "Japan"
        case .US:    return "United States"
        case .KR:    return "Korea"
        case .FR:    return "France"
        case .DE:    return "Germany"
        case .NL:    return "Netherlands"
        case .OTHER: return "Other"
        }
    }
}
