//
//  TalentOnboardingViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class TalentOnboardingViewController: BaseViewController {
    
    private let talentOnboardingView = TalentOnboardingView()
    
    private var talentDummy = Talent.talents()
    var selectedIndexPaths: Set<IndexPath> = [] {
        didSet {
            talentOnboardingView.nextButton.isEnabled = (!selectedIndexPaths.isEmpty)
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
    
    override func setLayout() {
        view.addSubviews(talentOnboardingView)
        
        talentOnboardingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setAddTarget() {
        talentOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        talentOnboardingView.talentCollectionView.delegate = self
        talentOnboardingView.talentCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        talentOnboardingView.talentCollectionView.register(TalentCollectionViewCell.self, forCellWithReuseIdentifier: TalentCollectionViewCell.className)
        talentOnboardingView.talentCollectionView.register(TalentHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TalentHeaderView.className)
    }
    
    @objc private func nextButtonTapped() {
        let portfolioOnboardingViewController = PortfolioOnboardingViewController()
        self.navigationController?.pushViewController(portfolioOnboardingViewController, animated: true)
    }
}

extension TalentOnboardingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TalentOnboardingViewController: UICollectionViewDelegate { }

extension TalentOnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return talentDummy[0].talent.count
        case 1:
            return talentDummy[1].talent.count
        case 2:
            return talentDummy[2].talent.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TalentCollectionViewCell.className,
            for: indexPath) as? TalentCollectionViewCell else { return UICollectionViewCell() }
        switch indexPath.section {
        case 0:
            cell.talentButton.setTitle(talentDummy[0].talent[indexPath.item], for: .normal)
        case 1:
            cell.talentButton.setTitle(talentDummy[1].talent[indexPath.item], for: .normal)
        case 2:
            cell.talentButton.setTitle(talentDummy[2].talent[indexPath.item], for: .normal)
        default:
            return cell
        }
        cell.num = indexPath.section
        cell.updateButtonAction = {
            if self.selectedIndexPaths.contains(indexPath) {
                self.selectedIndexPaths.remove(indexPath)
            } else {
                self.selectedIndexPaths.insert(indexPath)
            }
            print(self.selectedIndexPaths)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TalentHeaderView.className, for: indexPath) as? TalentHeaderView else {
                return TalentHeaderView()
            }
            let titleArray = [StringLiterals.Onboarding.Talent.design,
                              StringLiterals.Onboarding.Talent.art,
                              StringLiterals.Onboarding.Talent.media]
            header.setUI()
            header.talentTitle.text = titleArray[indexPath.section]
            return header
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 21.adjustedHeight
        return CGSize(width: width, height: height)
    }
}

extension TalentOnboardingViewController: UICollectionViewDelegateFlowLayout {
    // MARK: Dynamic height calculation
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = CGSize(width: (SizeLiterals.Screen.screenWidth - 70.adjustedWidth) / 3, height: 19)
        return size
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
}
