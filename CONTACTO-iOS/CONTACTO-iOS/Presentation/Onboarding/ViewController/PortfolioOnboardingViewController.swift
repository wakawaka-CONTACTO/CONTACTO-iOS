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

final class PortfolioOnboardingViewController: BaseViewController {
    
    private let portfolioOnboardingView = PortfolioOnboardingView()
    
    var selectedImages: [UIImage] = [] {
        didSet {
            portfolioOnboardingView.nextButton.isEnabled = (!selectedImages.isEmpty)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
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
        let mainTabBarViewController = MainTabBarViewController()
        navigationController?.pushViewController(mainTabBarViewController, animated: true)
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
        var configuration = PHPickerConfiguration()
        lazy var picker = PHPickerViewController(configuration: configuration)
        configuration.selectionLimit = 10 - selectedImages.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
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
        
        print(selectedImages)
        if indexPath.row < selectedImages.count {
            cell.isFilled = true
            cell.backgroundImageView.image = selectedImages[indexPath.row]
        } else {
            cell.isFilled = false
            cell.backgroundImageView.image = nil
        }
        
        cell.uploadAction = {
            self.setPortfolio()
        }
        
        cell.cancelAction = {
            self.selectedImages.remove(at: indexPath.row)
            collectionView.reloadData()
        }
        return cell
    }
}

extension PortfolioOnboardingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        if !self.selectedImages.contains(where: { $0.isEqualTo(image) }), self.selectedImages.count < 10  {
                            self.selectedImages.append(image)
                        }
                        self.portfolioOnboardingView.portfolioCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
