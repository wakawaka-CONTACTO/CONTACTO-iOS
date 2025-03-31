//
//  PortfolioItemManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/19/25.
//
import UIKit
import Kingfisher

final class PortfolioManager {

    private(set) var originalData: MyDetailResponseDTO?
    
    var currentData: MyDetailResponseDTO
    
    var portfolioItems: [PortfolioItem] = []
    
    init(portfolioData: MyDetailResponseDTO) {
        self.originalData = portfolioData
        self.currentData = portfolioData
        
        if let urls = portfolioData.userPortfolio?.portfolioImageUrl {
            self.portfolioItems = urls.map { PortfolioItem(isExistedSource: true, url: $0, image: nil) }
        }
    }
    
    func update(with newData: MyDetailResponseDTO) {
        self.currentData = newData
        self.portfolioItems.removeAll()
        if let urls = newData.userPortfolio?.portfolioImageUrl {
            self.portfolioItems = urls.map { PortfolioItem(isExistedSource: true, url: $0, image: nil) }
        }
    }
    
    func updatePortfolioItems(completion: @escaping () -> Void) {
        self.portfolioItems.removeAll()
        let existingUrls = currentData.userPortfolio?.portfolioImageUrl ?? []
        for urlString in existingUrls {
            let item = PortfolioItem(isExistedSource: true, url: urlString, image: nil)
            self.portfolioItems.append(item)
        }
        
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
        print("Nationality info for request: \(currentData.nationality)")
        
        return EditRequestBodyDTO(
            username: currentData.username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: currentData.email,
            description: currentData.description,
            instagramId: currentData.instagramId,
            password: "", // 비밀번호는 별도 처리
            webUrl: currentData.webUrl,
            nationality: currentData.nationality,
            userPurposes: currentData.userPurposes.map { $0 },
            userTalents: convertToTalent(displayNames: currentData.userTalents.map { $0.talentType }),
            newPortfolioImages: newPortfolioImages.isEmpty ? nil : newPortfolioImages,
            newImageKeys: newImageKeys.isEmpty ? nil : newImageKeys,
            existedImageUrl: existedImageUrl.isEmpty ? nil : existedImageUrl,
            existingImageKeys: existingImageKeys.isEmpty ? nil : existingImageKeys
        )
    }
    
    func convertToTalent(displayNames: [String]) -> [String] {
        return displayNames.compactMap { displayName in
            if let talent = Talent.allCases.first(where: { $0.info.displayName == displayName || $0.info.koreanName == displayName }) {
                return talent.rawValue
            } else {
#if DEBUG
                print("talent is not selected - displayName: \(displayName)")
#endif
                return nil
            }
        }
    }

    func hasChanges(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let originalData = self.originalData else {
                DispatchQueue.main.async {
                    completion(true)
                }
                return
            }
            
            var changeDetected = self.currentData.username != originalData.username ||
                self.currentData.description != originalData.description ||
                self.currentData.instagramId != originalData.instagramId ||
                self.currentData.webUrl != originalData.webUrl ||
                self.currentData.userPurposes.sorted() != originalData.userPurposes.sorted() ||
                self.currentData.userTalents.map({ $0.talentType }).sorted() != originalData.userTalents.map({ $0.talentType }).sorted()
            
            if changeDetected {
                DispatchQueue.main.async {
                    completion(true)
                }
                return
            }
            
            let originalURLs = originalData.userPortfolio?.portfolioImageUrl ?? []
            let currentExistingURLs = self.portfolioItems.compactMap { $0.isExistedSource ? $0.url : nil }
            
            if originalURLs.count != currentExistingURLs.count ||
                !zip(originalURLs.sorted(), currentExistingURLs.sorted()).allSatisfy({ $0 == $1 }) {
                changeDetected = true
            }
            
            let newImagesCount = self.portfolioItems.filter { !$0.isExistedSource }.count
            if newImagesCount > 0 {
                changeDetected = true
            }
            
            DispatchQueue.main.async {
                completion(changeDetected)
            }
        }
    }
}
