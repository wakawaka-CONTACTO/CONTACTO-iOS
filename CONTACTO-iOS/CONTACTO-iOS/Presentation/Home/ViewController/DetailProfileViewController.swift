//
//  DetailProfileViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import SnapKit
import Then

final class DetailProfileViewController: BaseViewController {
    
    var imageArray: [UIImage] = [.imgex1, .imgex2, .imgex3, .imgex4]
    var currentNum = 0 {
        didSet {
            print("바뀌다")
        }
    }
    
    let detailProfileView = DetailProfileView()
    var port: Portfolio = Portfolio(image: [], name: "", talent: [], description: "", purpose: [], insta: "", web: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        setCollectionView()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(detailProfileView)
        
        detailProfileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setAddTarget() {
        detailProfileView.popButton.addTarget(self, action: #selector(popButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        detailProfileView.portImageCollectionView.delegate = self
        detailProfileView.portImageCollectionView.dataSource = self
        detailProfileView.pageCollectionView.delegate = self
        detailProfileView.pageCollectionView.dataSource = self
        detailProfileView.talentCollectionView.delegate = self
        detailProfileView.talentCollectionView.dataSource = self
        detailProfileView.purposeCollectionView.delegate = self
        detailProfileView.purposeCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        detailProfileView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
        detailProfileView.purposeCollectionView.register(ProfilePurposeCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePurposeCollectionViewCell.className)
        detailProfileView.portImageCollectionView.register(ProfileImageCollectionViewCell.self, forCellWithReuseIdentifier: ProfileImageCollectionViewCell.className)
        detailProfileView.pageCollectionView.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.className)
    }
    
    private func setData() {
        // data 받는 곳
        port = Portfolio.portDummy()
        detailProfileView.talentCollectionView.reloadData()
        detailProfileView.talentCollectionView.layoutIfNeeded()
        detailProfileView.purposeCollectionView.layoutIfNeeded()
        
        detailProfileView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(detailProfileView.nameLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(46)
            $0.height.equalTo(detailProfileView.talentCollectionView.contentSize.height + 10)
        }
        
        detailProfileView.purposeCollectionView.snp.remakeConstraints {
            $0.top.equalTo(detailProfileView.purposeLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(detailProfileView.purposeCollectionView.contentSize.height)
        }
    }
    
    @objc private func popButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailProfileViewController: UICollectionViewDelegate { }

extension DetailProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0, 1:
            return port.image.count
        case 2:
            return port.talent.flatMap { $0.talent }.count
        case 3:
            return port.purpose.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileImageCollectionViewCell.className,
                for: indexPath) as? ProfileImageCollectionViewCell else { return UICollectionViewCell() }
            cell.portImageView.image = imageArray[indexPath.row]
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PageCollectionViewCell.className,
                for: indexPath) as? PageCollectionViewCell else { return UICollectionViewCell() }
            if indexPath.row == currentNum {
                cell.selectedView()
            } else {
                cell.unselectedView()
            }
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileTalentCollectionViewCell.className,
                for: indexPath) as? ProfileTalentCollectionViewCell else { return UICollectionViewCell() }
            
            let allTalents = port.talent.flatMap { $0.talent }
            let category = port.talent.first { $0.talent.contains(allTalents[indexPath.row]) }?.category ?? ""
            let title = allTalents[indexPath.row]
            
            cell.configData(category: category, title: title)
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfilePurposeCollectionViewCell.className,
                for: indexPath) as? ProfilePurposeCollectionViewCell else { return UICollectionViewCell() }
            cell.config(num: port.purpose[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
extension DetailProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
        case 0:
            return CGSize(width: SizeLiterals.Screen.screenWidth, height: 432)
        case 1:
            let totalItems = port.image.count
            
            let collectionViewWidth = collectionView.frame.width
            let spacing: CGFloat = 20.adjustedWidth
            
            let cellWidth = (collectionViewWidth - CGFloat(totalItems - 1) * spacing) / CGFloat(totalItems)
            return CGSize(width: cellWidth, height: collectionView.frame.height)
        case 2:
           return CGSize(width: .bitWidth, height: 19)
        case 3:
            return CGSize(width: 168.adjustedWidth, height: 28)
        default:
            return .zero
        }
    }
}
