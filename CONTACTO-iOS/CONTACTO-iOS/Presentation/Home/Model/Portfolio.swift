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
    let talent: [Talent]
    let description: String
    let purpose: [Int]
    let insta: String
    let web: String?
}

extension Portfolio {
    static func portDummy() -> Portfolio {
        let port = Portfolio(
            image: ["a", "b", "c"],
            name: "Pacay Pacay",
            talent: [Talent(talent: ["Branding", "Grapics", "Motion Grapics", "Illustration"], category: "design"),
                     Talent(talent: ["Printmaking"], category: "art"),
                     Talent(talent: ["Writing"], category: "media")],
            description: "안녕하세요떵개입니다오늘먹방은정채은입니다",
            purpose: [0, 3],
            insta: "chaentopia",
            web: "www.naver.com")
        return port
    }
}
