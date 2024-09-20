//
//  Talent.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import Foundation

struct Talent: Codable {
    let talent: [String]
    let category: String
}

extension Talent {
    static func talents() -> [Talent] {
        var talents: [Talent] = []
        
        let designArray = ["Industrial", "Graphic", "Fashion", "UX/UI", "Branding", "Motion Grapic",
                           "Animation", "Illustration", "Interior", "Architecture", "Textile",
                           "Fabric Product","Styling", "Bag Design", "Shoes Design"]
        let artArray = ["Painting", "Ridicule", "Kinetic", "Ceramics", "Wood", "Jewel",
                        "Metal", "Glass", "Printmaking", "Aesthetics", "Tuffting"]
        let mediaArray = ["Poet", "Writing", "Photo", "Advertising", "Scenario", "Compose",
                          "Writing", "Director", "Dance", "Sing", "Musical", "Comedy", "Act",
                          "Production", "Compose"]
        
        talents.append(Talent(talent: designArray,
                              category: "design"))
        talents.append(Talent(talent: artArray,
                       category: "art"))
        talents.append(Talent(talent: mediaArray,
                       category: "media"))
        
        return talents
    }
}
