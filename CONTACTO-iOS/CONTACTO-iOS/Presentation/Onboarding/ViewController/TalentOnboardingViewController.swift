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
    
    let talentOnboardingView = TalentOnboardingView()
    
    private var talentDummy: [[TalentInfo]] = [
        Talent.allCases.filter { $0.info.category == .DESIGN }.map { $0.info },
        Talent.allCases.filter { $0.info.category == .ART_CRAFT }.map { $0.info },
        Talent.allCases.filter { $0.info.category == .MEDIA_CONTENT }.map { $0.info }
    ]
    
    var isEdit = false
    var editTalent: [TalentInfo] = [] {
        didSet {
            talentOnboardingView.nextButton.isEnabled = (!editTalent.isEmpty)
        }
    }
    
    var updateTalent: (() -> Void) = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        self.sendAmpliLog(eventName: EventName.VIEW_ONBOARDING5)
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
    
    @objc func nextButtonTapped() {
        if isEdit {
            self.navigationController?.popViewController(animated: true)
            self.editTalent.sort { (first, second) -> Bool in
                guard let firstIndex = Talent.allCases.firstIndex(where: { $0.info.koreanName == first.koreanName }),
                      let secondIndex = Talent.allCases.firstIndex(where: { $0.info.koreanName == second.koreanName }) else {
                    return false
                }
                return firstIndex < secondIndex
            }
            updateTalent()
        } else {
            let selectedTalents = editTalent.compactMap { talentInfo in
                Talent.allCases.first(where: { $0.info.koreanName == talentInfo.koreanName })?.rawValue
            }
            UserInfo.shared.userTalents = selectedTalents
            let talent_count = selectedTalents.count
            sendAmpliLog(eventName: EventName.CLICK_ONBOARDING5_NEXT, properties: ["talent_count":  talent_count])
            let portfolioOnboardingViewController = PortfolioOnboardingViewController()
            self.navigationController?.pushViewController(portfolioOnboardingViewController, animated: true)
        }
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
            return Talent.allCases.filter { $0.info.category == .DESIGN }.count
        case 1:
            return Talent.allCases.filter { $0.info.category == .ART_CRAFT }.count
        case 2:
            return Talent.allCases.filter { $0.info.category == .MEDIA_CONTENT }.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TalentCollectionViewCell.className,
            for: indexPath) as? TalentCollectionViewCell else { return UICollectionViewCell() }
        let talent = talentDummy[indexPath.section][indexPath.row]
        
        let isSelected = editTalent.contains { $0.koreanName == talent.koreanName }
        cell.setTalent(talent, isSelectedFromEditTalent: isSelected)
        
        cell.updateButtonAction = {
            if let talentIndex = self.editTalent.firstIndex(where: { $0.koreanName == cell.talent.koreanName }) {
                self.editTalent.remove(at: talentIndex)
            } else {
                self.editTalent.append(cell.talent)
            }
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
        let size = CGSize(width: (SizeLiterals.Screen.screenWidth - 73.adjustedWidth) / 3, height: 25)
        return size
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
}
