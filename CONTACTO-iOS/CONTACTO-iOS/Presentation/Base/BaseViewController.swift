//
//  BaseViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/11/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: Properties
    
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    // MARK: Initializing
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("DEINIT: \(className)")
        #endif
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegate()
        setAddTarget()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        UserIdentityManager.setUserId()
    }
    
    // MARK: UI
    func setUI() {
        setStyle()
        setLayout()
    }
    
    func setStyle() {
        view.backgroundColor = .ctblack
    }
    
    func setLayout() {
        
    }
    
    func setNavigationBar() {
        
    }
    
    func setDelegate() {
        
    }
    
    func setAddTarget() {
        
    }
}

extension BaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
