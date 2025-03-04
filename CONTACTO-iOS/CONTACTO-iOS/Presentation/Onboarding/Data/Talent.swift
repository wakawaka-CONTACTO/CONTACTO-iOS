//
//  Talent.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

struct TalentInfo: Codable {
    let koreanName: String
    let displayName: String
    let category: TalentCategory
}

enum Talent: String, CaseIterable {
    // Design
    case INDUSTRIAL
    case GRAPHIC
    case FASHION
    case UX_UI // = "UX/UI"
    case BRANDING
    case MOTION_GRAPHIC //MOTION
    case ANIMATION
    case ILLUSTRATION
    case INTERIOR
    case ARCHITECTURE
    case TEXTILE
    case FABRIC_PRODUCT
    case STYLING
    case BAG_DESIGN
    case SHOES_DESIGN

    // Art & Craft
    case PAINTING
    case RIDICULE
    case KINETIC
    case CERAMICS
    case WOOD
    case JEWEL
    case METAL
    case GLASS
    case PRINTMAKING
    case AESTHETICS
    case TUFTING

    // Media & Content
    case POET
    case WRITING
    case PHOTO
    case ADVERTISING
    case SCENARIO
    case COMPOSE
    case DIRECTOR
    case DANCE
    case SING
    case MUSICAL
    case COMEDY
    case ACT
    case PRODUCTION

    
    var category: TalentCategory {
        switch self {
        case .INDUSTRIAL, .GRAPHIC, .FASHION, .UX_UI, .BRANDING, .MOTION_GRAPHIC, .ANIMATION, .ILLUSTRATION, .INTERIOR, .ARCHITECTURE, .TEXTILE, .FABRIC_PRODUCT, .STYLING, .BAG_DESIGN, .SHOES_DESIGN:
            return .DESIGN
        case .PAINTING, .RIDICULE, .KINETIC, .CERAMICS, .WOOD, .JEWEL, .METAL, .GLASS, .PRINTMAKING, .AESTHETICS, .TUFTING:
            return .ART_CRAFT
        case .POET, .WRITING, .PHOTO, .ADVERTISING, .SCENARIO, .COMPOSE, .DIRECTOR, .DANCE, .SING, .MUSICAL, .COMEDY, .ACT, .PRODUCTION:
            return .MEDIA_CONTENT
        }
    }
    
    var info: TalentInfo {
        switch self {
        case .INDUSTRIAL:
            return TalentInfo(koreanName: "산업 디자인", displayName: "Industrial", category: .DESIGN)
        case .GRAPHIC:
            return TalentInfo(koreanName: "그래픽 디자인", displayName: "Graphic", category: .DESIGN)
        case .FASHION:
            return TalentInfo(koreanName: "패션 디자인", displayName: "Fashion", category: .DESIGN)
        case .UX_UI:
            return TalentInfo(koreanName: "UX/UI 디자인", displayName: "UX/UI", category: .DESIGN)
        case .BRANDING:
            return TalentInfo(koreanName: "브랜딩", displayName: "Branding", category: .DESIGN)
        case .MOTION_GRAPHIC:
            return TalentInfo(koreanName: "모션 그래픽", displayName: "Motion", category: .DESIGN)
        case .ANIMATION:
            return TalentInfo(koreanName: "애니메이션", displayName: "Animation", category: .DESIGN)
        case .ILLUSTRATION:
            return TalentInfo(koreanName: "일러스트레이션", displayName: "Illustration", category: .DESIGN)
        case .INTERIOR:
            return TalentInfo(koreanName: "인테리어 디자인", displayName: "Interior", category: .DESIGN)
        case .ARCHITECTURE:
            return TalentInfo(koreanName: "건축 디자인", displayName: "Architecture", category: .DESIGN)
        case .TEXTILE:
            return TalentInfo(koreanName: "텍스타일", displayName: "Textile", category: .DESIGN)
        case .FABRIC_PRODUCT:
            return TalentInfo(koreanName: "패브릭 제품", displayName: "Fabric Product", category: .DESIGN)
        case .STYLING:
            return TalentInfo(koreanName: "스타일링", displayName: "Styling", category: .DESIGN)
        case .BAG_DESIGN:
            return TalentInfo(koreanName: "가방 디자인", displayName: "Bag Design", category: .DESIGN)
        case .SHOES_DESIGN:
            return TalentInfo(koreanName: "신발 디자인", displayName: "Shoes Design", category: .DESIGN)

        case .PAINTING:
            return TalentInfo(koreanName: "회화", displayName: "Painting", category: .ART_CRAFT)
        case .RIDICULE:
            return TalentInfo(koreanName: "조소", displayName: "Ridicule", category: .ART_CRAFT)
        case .KINETIC:
            return TalentInfo(koreanName: "키네틱 아트", displayName: "Kinetic", category: .ART_CRAFT)
        case .CERAMICS:
            return TalentInfo(koreanName: "도자기", displayName: "Ceramics", category: .ART_CRAFT)
        case .WOOD:
            return TalentInfo(koreanName: "목공", displayName: "Wood", category: .ART_CRAFT)
        case .JEWEL:
            return TalentInfo(koreanName: "주얼리", displayName: "Jewel", category: .ART_CRAFT)
        case .METAL:
            return TalentInfo(koreanName: "금속 공예", displayName: "Metal", category: .ART_CRAFT)
        case .GLASS:
            return TalentInfo(koreanName: "유리 공예", displayName: "Glass", category: .ART_CRAFT)
        case .PRINTMAKING:
            return TalentInfo(koreanName: "판화", displayName: "Printmaking", category: .ART_CRAFT)
        case .AESTHETICS:
            return TalentInfo(koreanName: "미학", displayName: "Aesthetics", category: .ART_CRAFT)
        case .TUFTING:
            return TalentInfo(koreanName: "터프팅", displayName: "Tufting", category: .ART_CRAFT)

        case .POET:
            return TalentInfo(koreanName: "시인", displayName: "Poet", category: .MEDIA_CONTENT)
        case .WRITING:
            return TalentInfo(koreanName: "글쓰기", displayName: "Writing", category: .MEDIA_CONTENT)
        case .PHOTO:
            return TalentInfo(koreanName: "사진", displayName: "Photo", category: .MEDIA_CONTENT)
        case .ADVERTISING:
            return TalentInfo(koreanName: "광고", displayName: "Advertising", category: .MEDIA_CONTENT)
        case .SCENARIO:
            return TalentInfo(koreanName: "시나리오", displayName: "Scenario", category: .MEDIA_CONTENT)
        case .COMPOSE:
            return TalentInfo(koreanName: "작곡", displayName: "Compose", category: .MEDIA_CONTENT)
        case .DIRECTOR:
            return TalentInfo(koreanName: "감독", displayName: "Director", category: .MEDIA_CONTENT)
        case .DANCE:
            return TalentInfo(koreanName: "춤", displayName: "Dance", category: .MEDIA_CONTENT)
        case .SING:
            return TalentInfo(koreanName: "노래", displayName: "Sing", category: .MEDIA_CONTENT)
        case .MUSICAL:
            return TalentInfo(koreanName: "뮤지컬", displayName: "Musical", category: .MEDIA_CONTENT)
        case .COMEDY:
            return TalentInfo(koreanName: "코미디", displayName: "Comedy", category: .MEDIA_CONTENT)
        case .ACT:
            return TalentInfo(koreanName: "연기", displayName: "Act", category: .MEDIA_CONTENT)
        case .PRODUCTION:
            return TalentInfo(koreanName: "제작", displayName: "Production", category: .MEDIA_CONTENT)
        }
    }
}

enum TalentCategory: String, Codable{
    case DESIGN = "디자인"
    case ART_CRAFT = "예술 공예"
    case MEDIA_CONTENT = "미디어 콘텐츠"
    
    var color: UIColor {
        switch self {
        case .DESIGN:
            return .ctsubpink
        case .ART_CRAFT:
            return .ctsubblue1
        case .MEDIA_CONTENT:
            return .ctsubbrown
        }
    }
}
