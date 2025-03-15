//
//  PortfoliosResponseDTO.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/9/24.
//

import Foundation

struct PortfoliosResponseDTO: Codable {
    let portfolioId: Double
    let userId: Int
    let username: String
    let portfolioImageUrl: [String]
}
