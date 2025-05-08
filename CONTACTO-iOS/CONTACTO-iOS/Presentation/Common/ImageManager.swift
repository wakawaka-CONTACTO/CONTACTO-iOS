//
//  ImageManager.swift
//  CONTACTO-iOS
//
//  Created by hana on 4/29/25.
//

import UIKit
import Kingfisher

final class ImageManager {
    static let shared = ImageManager()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let preloadingQueue = DispatchQueue(label: "com.contacto.preloading", qos: .userInitiated)
    private let tasksQueue = DispatchQueue(label: "com.contacto.tasks", qos: .userInitiated)
    private var imageLoadingTasks: [DownloadTask] = []
    private var shouldCancelPreloading = false
    
    // 프리로드할 이미지 개수 설정
    private let preloadCount = 2
    
    private init() {}
    
    // MARK: - Public Methods
    
    func loadImage(url: String, into imageView: UIImageView, completion: ((UIImage?) -> Void)? = nil) {
        // 캐시된 이미지 확인
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            imageView.image = cachedImage
            completion?(cachedImage)
            return
        }
        
        // 캐시에 없는 경우 비동기적으로 로드
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard let imageURL = URL(string: url) else {
                #if DEBUG
                print("잘못된 URL 형식: \(url)")
                #endif
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            let task = KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        imageView.image = value.image
                        self.imageCache.setObject(value.image, forKey: url as NSString)
                        completion?(value.image)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                    #if DEBUG
                      print("이미지 로딩 실패: \(error)")
                    #endif
                      completion?(nil)
                    }
                }
            }
            
            if let task = task {
                self.tasksQueue.async {
                    self.imageLoadingTasks.append(task)
                }
            }
        }
    }
    
    func preloadImages(urls: [String], startIndex: Int) {
        guard !shouldCancelPreloading, !urls.isEmpty else { return }
        
        // 다음 이미지들 프리로드
        let nextIndices = (1...preloadCount).map { (startIndex + $0) % urls.count }
        
        for index in nextIndices {
            let imageUrl = urls[index]
            
            // 이미 캐시된 이미지는 건너뛰기
            if imageCache.object(forKey: imageUrl as NSString) != nil { continue }
            
            preloadingQueue.async { [weak self] in
                guard let self = self, !self.shouldCancelPreloading else { return }
                
                guard let imageURL = URL(string: imageUrl) else {
                    #if DEBUG
                    print("잘못된 URL 형식: \(imageUrl)")
                    #endif
                    return
                }
                
                let task = KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
                    guard let self = self else { return }
                    
                    if case .success(let value) = result {
                        self.imageCache.setObject(value.image, forKey: imageUrl as NSString)
                    }
                }
                
                if let task = task {
                    self.tasksQueue.async {
                        self.imageLoadingTasks.append(task)
                    }
                }
            }
        }
    }
    
    // MARK: - Memory Management
    
    func cancelAllTasks() {
        tasksQueue.async { [weak self] in
            guard let self = self else { return }
            self.imageLoadingTasks.forEach { $0.cancel() }
            self.imageLoadingTasks.removeAll()
            self.shouldCancelPreloading = true
        }
    }
    
    func resumePreloading() {
        shouldCancelPreloading = false
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
    }
    
    func clearAll() {
        cancelAllTasks()
        clearCache()
    }
} 
