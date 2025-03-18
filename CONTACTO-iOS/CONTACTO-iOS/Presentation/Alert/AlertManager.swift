//
//  AlertManager.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 3/14/25.
//

import UIKit

struct AlertManager {
    static func showAlert(on viewController: UIViewController,
                          title: String = "Invalid Inputs",
                          message: String,
                          completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(confirmAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
