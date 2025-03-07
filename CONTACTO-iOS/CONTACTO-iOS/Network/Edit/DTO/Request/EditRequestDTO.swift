//
//  EditRequestDTO.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/7/25.
//

import Foundation

struct EditRequestDTO: Encodable{
    let username: String
    let email, description, instagramId, password: String
    let webUrl: String?
    let userPurposes: [Int]
    let userTalents: [String]
    // 새로 업로드할 이미지 데이터와 해당 순번
    let newPortfolioImages: [Data]?
    let newImageKeys: [Int]?
    // 기존 이미지 URL과 해당 순번
    let existingPortfolioImageUrls: [String]?
    let existingImageKeys: [Int]?
}
