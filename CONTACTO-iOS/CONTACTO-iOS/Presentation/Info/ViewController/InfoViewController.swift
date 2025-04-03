//
//  InfoViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/20/24.
//

import UIKit

import SafariServices
import SnapKit
import Then

final class InfoViewController: BaseViewController {
    private let infoView = InfoView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkMyPort { _ in }
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(infoView)
        
        infoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setAddTarget() {
        infoView.helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        infoView.guidelinesButton.addTarget(self, action: #selector(guidelinesTapped), for: .touchUpInside)
        infoView.cookieButton.addTarget(self, action: #selector(cookieButtonTapped), for: .touchUpInside)
        infoView.logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        infoView.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func checkMyPort(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.editService.checkMyPort { [weak self] response in
            switch response {
            case .success(let data):
                self?.infoView.emailLabel.text = data.email
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

extension InfoViewController {
    @objc private func helpButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.insta) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func guidelinesTapped() {
        guard let url = URL(string: StringLiterals.URL.guidelines) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc private func cookieButtonTapped() {
        guard let url = URL(string: StringLiterals.URL.privacy) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @objc private func logoutButtonTapped() {
        self.setLogoutAlertController()
    }
    
    @objc private func deleteButtonTapped() {
        self.setDeleteAlertController()
    }
    
    private func setLogoutAlertController() {
        let title = StringLiterals.Info.Alert.Logout.logoutTitle
        let description = StringLiterals.Info.Alert.Logout.logoutDescription
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: StringLiterals.Info.Alert.Logout.no, style: .cancel){ cancel in
            print("취소 버튼이 눌렸습니다.")
        }
        
        let success = UIAlertAction(title: StringLiterals.Info.Alert.Logout.yes, style: .default){ action in
            KeychainHandler.shared.accessToken.removeAll()
            KeychainHandler.shared.refreshToken.removeAll()
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }
        
        AmplitudeManager.amplitude.reset()
        alert.addAction(cancel)
        alert.addAction(success)
        present(alert, animated: true)
    }
    
    private func setDeleteAlertController() {
        let title = StringLiterals.Info.Alert.Delete.deleteTitle
        let description = StringLiterals.Info.Alert.Delete.deleteDescription
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let success = UIAlertAction(title: StringLiterals.Info.Alert.Delete.notYet, style: .default){ action in
            print("취소 버튼이 눌렸습니다.")
        }
        
        let cancel = UIAlertAction(title: StringLiterals.Info.Alert.Delete.delete, style: .destructive){ cancel in
            self.deleteMe { _ in
                KeychainHandler.shared.accessToken.removeAll()
                KeychainHandler.shared.refreshToken.removeAll()
                guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            }
        }
        
        alert.addAction(success)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    private func deleteMe(completion: @escaping (Bool) -> Void) {
        NetworkService.shared.infoService.deleteMe() { response in
            switch response {
            case .success(let data):
                completion(true)
            default:
                completion(false)
            }
        }
    }
}
