//
//  NSObject+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import Foundation

extension NSObject {
    static var className: String {
        NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
    }
}
