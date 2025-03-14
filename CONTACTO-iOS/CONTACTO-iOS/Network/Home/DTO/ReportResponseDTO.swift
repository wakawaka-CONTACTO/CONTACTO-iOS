//
//  ReportResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by hana on 3/13/25.
//

import Foundation

struct ReportResponseDTO: Codable {
    let userId: Int
    let reportedUserId: Int
    let reportReason: String
    let reportStatus: String
}
