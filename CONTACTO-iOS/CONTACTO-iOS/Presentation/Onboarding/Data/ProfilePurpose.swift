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
    case makenew
    case art
    case group

    var displayName: String {
        switch self {
        case .getalong:
            return StringLiterals.Onboarding.Purpose.getalong
        case .collaborate:
            return StringLiterals.Onboarding.Purpose.collaborate
        case .makenew:
            return StringLiterals.Onboarding.Purpose.makenew
        case .art:
            return StringLiterals.Onboarding.Purpose.art
        case .group:
            return StringLiterals.Onboarding.Purpose.group
        }
    }
    
    var color: UIColor {
        // color 배열과 순서가 맞도록 rawValue를 활용합니다.
        let colors: [UIColor] = [.ctsubred, .ctsubpink, .ctsubblue2, .ctsubyellow2, .ctsubgreen1]
        return colors[self.rawValue]
    }
}
