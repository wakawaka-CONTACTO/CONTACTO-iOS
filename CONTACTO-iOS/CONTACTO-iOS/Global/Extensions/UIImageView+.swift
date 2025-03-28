//
//  UIImageView+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 11/14/24.
//

import UIKit

import Kingfisher

extension UIImageView {
    func kfSetImage(url: String?) {
        
        guard let url = url else {
            print(url)
            return }
        
        if let url = URL(string: url) {
            kf.indicatorType = .activity
            kf.setImage(with: url,
                        placeholder: nil,
                        options: [.transition(.fade(1.0))], progressBlock: nil)
        }
    }
}
