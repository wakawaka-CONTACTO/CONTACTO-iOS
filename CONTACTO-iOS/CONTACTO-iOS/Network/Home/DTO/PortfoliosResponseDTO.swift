//
//  PortfoliosResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

/// list 형태
struct PortfoliosResponseDTO: Codable {
    let portfolioID: Double
    let userID: Int
    let username: String
    let portfolioImages: [String]
}
