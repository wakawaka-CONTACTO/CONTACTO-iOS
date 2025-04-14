//
//  ProfilePurpose.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/9/25.
//

import Foundation
import UIKit

enum ProfilePurpose: Int, CaseIterable {
    case getalong
    case collaborate
    case art
    case makenew
    case group

    var displayName: String {
        switch self {
        case .getalong:
            return StringLiterals.Onboarding.Purpose.getalong
        case .collaborate:
            return StringLiterals.Onboarding.Purpose.collaborate
        case .art:
            return StringLiterals.Onboarding.Purpose.art
        case .makenew:
            return StringLiterals.Onboarding.Purpose.makenew
        case .group:
            return StringLiterals.Onboarding.Purpose.group
        }
    }
    
    var color: UIColor {
        let colors: [UIColor] = [.ctsubred, .ctsubpink, .ctsubyellow2, .ctsubblue2, .ctsubgreen1]
        return colors[self.rawValue]
    }
}
