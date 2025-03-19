//
//  PortfolioItemManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/19/25.
//
import UIKit
import Kingfisher

/// 포트폴리오 관련 데이터를 관리하는 모듈
final class PortfolioManager {

    /// 초기(원본) 포트폴리오 데이터 (변경 감지에 사용)
    private(set) var originalData: MyDetailResponseDTO?
    
    /// 현재 포트폴리오 데이터 (UI 수정에 따른 변경 반영)
    var currentData: MyDetailResponseDTO
    
    /// 포트폴리오 이미지 및 관련 정보를 담은 아이템 배열
    var portfolioItems: [PortfolioItem] = []
    
    /// 초기 데이터를 전달받아 manager 초기화
    init(portfolioData: MyDetailResponseDTO) {
        self.originalData = portfolioData
        self.currentData = portfolioData
        
        // 기존 포트폴리오 이미지 URL이 있다면, PortfolioItem 생성
        if let urls = portfolioData.userPortfolio?.portfolioImageUrl {
            self.portfolioItems = urls.map { PortfolioItem(isExistedSource: true, url: $0, image: nil) }
        }
    }
    
    /// 서버로부터 새 데이터를 받은 경우 업데이트 처리
    func update(with newData: MyDetailResponseDTO) {
        self.currentData = newData
        self.portfolioItems.removeAll()
        if let urls = newData.userPortfolio?.portfolioImageUrl {
            self.portfolioItems = urls.map { PortfolioItem(isExistedSource: true, url: $0, image: nil) }
        }
    }
    
    /// 포트폴리오 아이템들을 업데이트(이미지 다운로드 포함)한 후 completion 호출
    func updatePortfolioItems(completion: @escaping () -> Void) {
        // 기존 아이템 초기화 및 URL로부터 아이템 재구성
        self.portfolioItems.removeAll()
        let existingUrls = currentData.userPortfolio?.portfolioImageUrl ?? []
        for urlString in existingUrls {
            let item = PortfolioItem(isExistedSource: true, url: urlString, image: nil)
            self.portfolioItems.append(item)
        }
        
        // 각 URL에서 이미지를 다운로드
        let dispatchGroup = DispatchGroup()
        for (index, urlString) in existingUrls.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            dispatchGroup.enter()
            KingfisherManager.shared.downloader.downloadImage(with: url) { result in
                if case .success(let value) = result {
                    DispatchQueue.main.async {
                        if index < self.portfolioItems.count {
                            self.portfolioItems[index].image = value.image
                        }
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    /// 포트폴리오 아이템 배열에서 신규 이미지와 기존 이미지를 분리하여
    /// 백엔드 전송용 EditRequestBodyDTO를 생성
    func prepareUpdateRequestBody() -> EditRequestBodyDTO {
        var newPortfolioImages: [Data] = []
        var existedImageUrl: [String] = []
        var newImageKeys: [Int] = []
        var existingImageKeys: [Int] = []
        
        for (index, item) in portfolioItems.enumerated() {
            if item.isExistedSource {
                if let url = item.url {
                    existedImageUrl.append(url)
                    existingImageKeys.append(index)
                }
            } else {
                if let imageData = item.image?.jpegData(compressionQuality: 0.8) {
                    newPortfolioImages.append(imageData)
                    newImageKeys.append(index)
                }
            }
        }
        
        return EditRequestBodyDTO(
            username: currentData.username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: currentData.email,
            description: currentData.description,
            instagramId: currentData.instagramId,
            password: "", // 비밀번호는 별도 처리
            webUrl: currentData.webUrl,
            userPurposes: currentData.userPurposes.map { $0 - 1 },
            userTalents: convertToTalent(displayNames: currentData.userTalents.map { $0.talentType }),
            newPortfolioImages: newPortfolioImages.isEmpty ? nil : newPortfolioImages,
            newImageKeys: newImageKeys.isEmpty ? nil : newImageKeys,
            existedImageUrl: existedImageUrl.isEmpty ? nil : existedImageUrl,
            existingImageKeys: existingImageKeys.isEmpty ? nil : existingImageKeys
        )
    }
    
    /// Talent 정보 변환 (DisplayName -> RawValue)
    func convertToTalent(displayNames: [String]) -> [String] {
        return displayNames.compactMap { displayName in
            if let talent = Talent.allCases.first(where: { $0.info.displayName == displayName }) {
                return talent.rawValue
            } else {
                return nil
            }
        }
    }
    
    /// 현재 포트폴리오 데이터와 원본 데이터를 비교하여 변경 여부를 감지
    func hasChanges(completion: @escaping (Bool) -> Void) {
        guard let originalData = originalData else {
            completion(true)
            return
        }
        
        // 텍스트, Purpose, Talent 변경 여부 확인
        var changeDetected = currentData.username != originalData.username ||
            currentData.description != originalData.description ||
            currentData.instagramId != originalData.instagramId ||
            currentData.webUrl != originalData.webUrl ||
            currentData.userPurposes.sorted() != originalData.userPurposes.sorted() ||
            currentData.userTalents.map({ $0.talentType }).sorted() != originalData.userTalents.map({ $0.talentType }).sorted()
        
        // 이미지 데이터 비교 (비동기 처리)
        let originalURLs = originalData.userPortfolio?.portfolioImageUrl.compactMap { URL(string: $0) } ?? []
        var originalImageData = [Data]()
        let group = DispatchGroup()
        
        for url in originalURLs {
            group.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    originalImageData.append(data)
                }
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            let selectedImageData = self.portfolioItems.compactMap { $0.image?.pngData() }
            changeDetected = changeDetected || (selectedImageData != originalImageData)
            completion(changeDetected)
        }
    }
}
