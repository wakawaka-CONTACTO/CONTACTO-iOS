//
//  UIImageView+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/14/24.
//

import UIKit

import Kingfisher

extension UIImageView {
    private func addResizeParams(to url: String, width: Int? = nil, height: Int? = nil) -> String {
            var components = URLComponents(string: url)
            var queryItems = components?.queryItems ?? []
            
            if let width = width {
                queryItems.append(URLQueryItem(name: "w", value: String(width)))
            }
            if let height = height {
                queryItems.append(URLQueryItem(name: "h", value: String(height)))
            }
            
            components?.queryItems = queryItems
            return components?.string ?? url
        }
    
    func kfSetImage(url: String?, width: Int? = nil, height: Int? = nil) {

        guard let url = url else {
            print(url)
            return
        }
        
        let resizedUrl = addResizeParams(to: url, width: width, height: height)
        
        if let url = URL(string: resizedUrl) {
            kf.indicatorType = .activity
            kf.setImage(with: url,
                        placeholder: nil,
                        options: [.transition(.fade(1.0))], progressBlock: nil)
        }
    }
}
