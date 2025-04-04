//
//  PortfolioOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import PhotosUI
import SnapKit
import Then
import FirebaseMessaging

final class PortfolioOnboardingViewController: BaseViewController, OnboadingAmplitudeSender {
    
    private let portfolioOnboardingView = PortfolioOnboardingView()
    private var isLoading = false
    
    var portfolioItems: [UIImage] = [] {
        didSet {
            portfolioOnboardingView.nextButton.isEnabled = (!portfolioItems.isEmpty)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING6)
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func setDelegate() {
        portfolioOnboardingView.portfolioCollectionView.delegate = self
        portfolioOnboardingView.portfolioCollectionView.dataSource = self
    }
    
    override func setAddTarget() {
        portfolioOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc private func nextButtonTapped() {
        isLoading = true
        portfolioOnboardingView.nextButton.isEnabled = false
        UserInfo.shared.portfolioImageUrl = self.portfolioItems.compactMap { $0.jpegData(compressionQuality: 0.8) }
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = UIDevice.current.model
        let portfolio_count = UserInfo.shared.portfolioImageUrl.count
        sendAmpliLog(eventName: EventName.CLICK_ONBOARDING6_NEXT, properties: ["portfolio_count" : portfolio_count])
        
        Messaging.messaging().token { firebaseToken, error in
            guard let firebaseToken = firebaseToken else {
                print("❌ FCM 토큰 가져오기 실패")
                return
            }

            let bodyData = SignUpRequestBodyDTO(
                userSignUpReq: UserSignUpRequest(
                    name: UserInfo.shared.name,
                    email: UserInfo.shared.email,
                    description: UserInfo.shared.description,
                    instagramId: UserInfo.shared.instagramId,
                    password: UserInfo.shared.password,
                    loginType: "LOCAL",
                    nationality: UserInfo.shared.nationality,
                    webUrl: UserInfo.shared.webUrl,
                    firebaseToken: firebaseToken,
                    deviceId: deviceId,
                    deviceType: deviceType),
                purpose: UserInfo.shared.userPurposes.map { Purpose(purposeType: $0) },
                talent: UserInfo.shared.userTalents.map { TalentType(talentType: $0) },
                images: UserInfo.shared.portfolioImageUrl)

            self.signup(bodyDTO: bodyData) { success in
                self.isLoading = false
                if success {
                    let mainTabBarViewController = MainTabBarViewController()
                    mainTabBarViewController.homeViewController.isFirst = true
                    self.navigationController?.pushViewController(mainTabBarViewController, animated: true)
                    
                } else {
                    let alertController = UIAlertController(
                        title: "Error",
                        message: "회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.",
                        preferredStyle: .alert)

                    let retryAction = UIAlertAction(title: "OK", style: .default) { _ in
                        alertController.dismiss(animated: true, completion: nil)
                    }

                    alertController.addAction(retryAction)
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.portfolioOnboardingView.nextButton.isEnabled = true
            }
        }
    }
    
    private func setCollectionView() {
        portfolioOnboardingView.portfolioCollectionView.register(PortfolioCollectionViewCell.self, forCellWithReuseIdentifier: PortfolioCollectionViewCell.className)
    }
    
    override func setLayout() {
        view.addSubviews(portfolioOnboardingView)
        
        portfolioOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setPortfolio() {
        guard !isLoading else { return }
        
        var configuration = PHPickerConfiguration()
        lazy var picker = PHPickerViewController(configuration: configuration)
        configuration.selectionLimit = 10 - portfolioItems.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
    
    private func signup(bodyDTO: SignUpRequestBodyDTO,completion: @escaping (Bool) -> Void) {
        NetworkService.shared.onboardingService.signup(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                KeychainHandler.shared.userID = String(data.userId)
                KeychainHandler.shared.accessToken = data.accessToken
                KeychainHandler.shared.refreshToken = data.refreshToken
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

extension PortfolioOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PortfolioOnboardingViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentWidth = scrollView.contentSize.width
        let visibleWidth = scrollView.bounds.width
        let contentOffsetX = scrollView.contentOffset.x
        
        let maxOffsetX = contentWidth - visibleWidth
        let indicatorWidth = 45.0
        let indicatorX = contentOffsetX / maxOffsetX * (portfolioOnboardingView.indicatorView.bounds.width - indicatorWidth)
        
        portfolioOnboardingView.indicatorView.trackTintView.snp.remakeConstraints {
            $0.width.equalTo(45)
            $0.top.bottom.height.equalTo(portfolioOnboardingView.indicatorView.trackView)
            $0.leading.equalToSuperview().offset(indicatorX)
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension PortfolioOnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PortfolioCollectionViewCell.className,
            for: indexPath) as? PortfolioCollectionViewCell else { return UICollectionViewCell() }
        
        if indexPath.row < portfolioItems.count {
            cell.isFilled = true
            cell.backgroundImageView.image = portfolioItems[indexPath.row]
        } else {
            cell.isFilled = false
            cell.backgroundImageView.image = nil
        }
        
        cell.uploadAction = {
            self.setPortfolio()
        }
        
        cell.cancelAction = {
            self.portfolioItems.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        return cell
    }
}

extension PortfolioOnboardingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        var addedImages: [UIImage?] = Array(repeating: nil, count: results.count)
        let group = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        if !self.portfolioItems.contains(where: { $0.isEqualTo(image) }), self.portfolioItems.count < 10  {
                            addedImages[index] = image
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let newImages = addedImages.compactMap { $0 }
            self.portfolioItems.append(contentsOf: newImages)
            self.portfolioOnboardingView.portfolioCollectionView.reloadData()
        }
    }
}
