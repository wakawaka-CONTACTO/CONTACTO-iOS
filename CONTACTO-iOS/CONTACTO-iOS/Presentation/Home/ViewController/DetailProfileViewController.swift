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
        detailProfileView.talentCollectionView.delegate = self
        detailProfileView.talentCollectionView.dataSource = self
        //        detailProfileView.purposeCollectionView.delegate = self
        //        detailProfileView.purposeCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        detailProfileView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
    }
    
    private func setData() {
        // data 받는 곳
        port = Portfolio.portDummy()
        detailProfileView.talentCollectionView.reloadData()
        detailProfileView.talentCollectionView.layoutIfNeeded()
        
        detailProfileView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(detailProfileView.nameLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(46)
            $0.height.equalTo(detailProfileView.talentCollectionView.contentSize.height + 1)
        }
    }
    
    @objc private func popButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailProfileViewController: UICollectionViewDelegate { }

extension DetailProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return port.talent.flatMap { $0.talent }.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileTalentCollectionViewCell.className,
            for: indexPath) as? ProfileTalentCollectionViewCell else { return UICollectionViewCell() }
        
        let allTalents = port.talent.flatMap { $0.talent }
        let category = port.talent.first { $0.talent.contains(allTalents[indexPath.row]) }?.category ?? ""
        let title = allTalents[indexPath.row]
        
        cell.configData(category: category, title: title)
        return cell
    }
}
