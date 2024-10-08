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
}
