//
//  Portfolio.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import Foundation

struct Portfolio: Codable {
    let image: [String]
    let name: String
    let talent: [TalentInfo]
    let description: String
    let purpose: [Int]
    let insta: String
    let web: String?
}

extension Portfolio {
    static func portDummy() -> Portfolio {
        let port = Portfolio(
            image: ["a", "b", "c", "d", "a", "b", "c"],
            name: "Pacay Pacay",
            talent: [],
            description:"We’re graphic design crew. 그래픽 공동체 @pacay.pacay의 첫 번째 전시 [ARCHIVE: *860 FELL STREET]을 위한 플레이리스트를 공유합니다.",
            purpose: [0, 2, 3],
            insta: "contacto.creator",
            web: "contactocreator.com")
        return port
    }
}
