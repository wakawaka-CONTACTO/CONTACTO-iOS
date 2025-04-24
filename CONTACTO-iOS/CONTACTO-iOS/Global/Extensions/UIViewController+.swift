//
//  UIViewController+.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var safeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows[0]
        let safeTop = window.safeAreaInsets.top
        let safeBottom = window.safeAreaInsets.bottom
        let height = window.frame.height - (safeTop + safeBottom)
        return height
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = .fontContacto(.caption1)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let toastWidth = message.size(withAttributes: [.font: UIFont.fontContacto(.caption1)]).width + 40
        let toastHeight: CGFloat = 35
        
        toastLabel.frame = CGRect(x: self.view.frame.size.width/2 - toastWidth/2,
                                 y: self.view.frame.size.height-100,
                                 width: toastWidth,
                                 height: toastHeight)
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 3.5, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
