//
//  ReportRequestBodyDTO.swift
//  CONTACTO-iOS
//
//  Created by hana on 3/13/25.
//

import Foundation

struct ReportRequestBodyDTO: Codable {
    let reportedUserId: Int
    let reportReasonIdx: Int
}
