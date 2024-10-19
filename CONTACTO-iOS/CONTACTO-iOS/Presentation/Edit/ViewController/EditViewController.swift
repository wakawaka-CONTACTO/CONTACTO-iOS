//
//  EditViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/7/24.
//

import UIKit

import PhotosUI
import SnapKit
import Then

final class EditViewController: BaseViewController {
    
    private var talentDummy = Talent.talents()
    
    var selectedImages: [UIImage] = []
    let editView = EditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        setData()
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(editView)
        
        editView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    override func setAddTarget() {
        editView.previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        editView.talentEditButton.addTarget(self, action: #selector(talentEditButtonTapped), for: .touchUpInside)
    }
    
    override func setDelegate() {
        editView.portfolioCollectionView.delegate = self
        editView.portfolioCollectionView.dataSource = self
        editView.talentCollectionView.delegate = self
        editView.talentCollectionView.dataSource = self
        editView.purposeCollectionView.delegate = self
        editView.purposeCollectionView.dataSource = self
    }
    
    private func setCollectionView() {
        editView.portfolioCollectionView.register(EditPortfolioCollectionViewCell.self, forCellWithReuseIdentifier: EditPortfolioCollectionViewCell.className)
        editView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
        editView.purposeCollectionView.register(ProfilePurposeCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePurposeCollectionViewCell.className)
    }
    
    private func setData() {
        //data 받는 곳
        
        editView.talentCollectionView.layoutIfNeeded()
        
        editView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(editView.talentLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(editView.talentCollectionView.contentSize.height)
        }
    }
    
    func setPortfolio() {
        var configuration = PHPickerConfiguration()
        lazy var picker = PHPickerViewController(configuration: configuration)
        configuration.selectionLimit = 4 - selectedImages.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
}

extension EditViewController {
    @objc private func previewButtonTapped() {
        // layout, style, navigation 등 수정 필요 - feature
        let previewViewController = HomeViewController()
        present(previewViewController, animated: true)
    }
    
    @objc private func talentEditButtonTapped() {
        let talentViewController = TalentOnboardingViewController()
        talentViewController.hidesBottomBarWhenPushed = true
        talentViewController.talentOnboardingView.nextButton.setTitle(StringLiterals.Edit.doneButton, for: .normal)
        navigationController?.pushViewController(talentViewController, animated: true)
    }
}

extension EditViewController: UICollectionViewDelegate { }

extension EditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 4
        case 1:
            return talentDummy.flatMap { $0.talent }.count
        case 2:
            return 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EditPortfolioCollectionViewCell.className,
                for: indexPath) as? EditPortfolioCollectionViewCell else { return UICollectionViewCell() }
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
                self.selectedImages.remove(at: cell.tag)
                collectionView.reloadData()
            }
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileTalentCollectionViewCell.className,
                for: indexPath) as? ProfileTalentCollectionViewCell else { return UICollectionViewCell() }
            
            let allTalents = talentDummy.flatMap { $0.talent }
            let category = talentDummy.first { $0.talent.contains(allTalents[indexPath.row]) }?.category ?? ""
            let title = allTalents[indexPath.row]
            
            cell.configData(category: category, title: title)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfilePurposeCollectionViewCell.className,
                for: indexPath) as? ProfilePurposeCollectionViewCell else { return UICollectionViewCell() }
            cell.config(num: indexPath.row)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension EditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        if !self.selectedImages.contains(where: { $0.isEqualTo(image) }), self.selectedImages.count < 4  {
                            self.selectedImages.append(image)
                        }
                        self.editView.portfolioCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

