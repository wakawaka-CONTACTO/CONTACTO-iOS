//
//  PortfolioOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class PortfolioOnboardingViewController: BaseViewController {
    
    private let portfolioOnboardingView = PortfolioOnboardingView()
    
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
    
    private func setCollectionView() {
        portfolioOnboardingView.portfolioCollectionView.register(PortfolioCollectionViewCell.self, forCellWithReuseIdentifier: PortfolioCollectionViewCell.className)
    }
    
    override func setLayout() {
        view.addSubviews(portfolioOnboardingView)
        
        portfolioOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PortfolioOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PortfolioOnboardingViewController: UICollectionViewDelegate { }

extension PortfolioOnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PortfolioCollectionViewCell.className,
            for: indexPath) as? PortfolioCollectionViewCell else { return UICollectionViewCell() }
        return cell
    }
}
