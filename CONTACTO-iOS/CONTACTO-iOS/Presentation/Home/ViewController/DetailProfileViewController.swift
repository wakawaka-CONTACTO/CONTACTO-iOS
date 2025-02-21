//
//  DetailProfileViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 9/19/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class DetailProfileViewController: BaseViewController {
    
    var imageArray: [String] = []
    var imagePreviewDummy: [UIImage] = []
    var currentNum = 0 {
        didSet {
            detailProfileView.pageCollectionView.reloadData()
        }
    }
    var userId: Int = 3
    var isPreview = false
    
    let detailProfileView = DetailProfileView()
    var portfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []), userPurposes: [], userTalents: [])
    private var talentData: [TalentInfo] = []
    
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
        detailProfileView.instaButton.addTarget(self, action: #selector(instaButtonTapped), for: .touchUpInside)
        detailProfileView.webButton.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Server Function
    private func detailPort(userId: Int, completion: @escaping (Bool) -> Void) {
        if !isPreview {
            NetworkService.shared.homeService.detailPort(userId: userId) { [weak self] response in
                switch response {
                case .success(let data):
                    self?.portfolioData = data
                    self?.updatePortfolio()
                    print(data)
                    completion(true)
                default:
                    completion(false)
                    print("error")
                }
            }
        } else {
            self.updatePortfolio()
        }
        completion(true)
    }
    
    private func updatePortfolio() {
        self.talentData = self.portfolioData.userTalents.compactMap { userTalent in
            if self.isPreview {
                return Talent.allCases.first(where: { $0.info.displayName == userTalent.talentType })?.info
            } else {
                return Talent.allCases.first(where: { $0.info.koreanName == userTalent.talentType })?.info
            }
        }
        
        if !isPreview {
            self.imageArray = portfolioData.userPortfolio?.portfolioImageUrl ?? []
            self.detailProfileView.portImageCollectionView.reloadData()
            self.detailProfileView.pageCollectionView.reloadData()
        }
        
        self.detailProfileView.nameLabel.text = self.portfolioData.username
        self.detailProfileView.descriptionLabel.text = self.portfolioData.description
        if self.portfolioData.webUrl != nil {
            self.detailProfileView.webButton.isHidden = false
        } else {
            self.detailProfileView.webButton.isHidden = true
        }
        
        self.detailProfileView.talentCollectionView.reloadData()
        self.detailProfileView.purposeCollectionView.reloadData()
        self.resetCollectionViewLayout()
    }
    
    private func setData() {
        detailPort(userId: userId) { _ in }
    }
    
    private func resetCollectionViewLayout() {
        self.detailProfileView.talentCollectionView.layoutIfNeeded()
        self.detailProfileView.purposeCollectionView.layoutIfNeeded()
        
        self.detailProfileView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(self.detailProfileView.nameLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(46)
            $0.height.equalTo(self.detailProfileView.talentCollectionView.contentSize.height + 10)
        }
        
        self.detailProfileView.purposeCollectionView.snp.remakeConstraints {
            $0.top.equalTo(self.detailProfileView.purposeLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(self.detailProfileView.purposeCollectionView.contentSize.height)
        }
    }
    
    @objc private func instaButtonTapped() {
        let id = portfolioData.instagramId
        let url = URL(string: "https://www.instagram.com/\(id)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func webButtonTapped() {
        guard let url = URL(string: portfolioData.webUrl ?? "google.com") else {
            print("url error")
            return
        }
        
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            guard let chatURL = URL(string: "https://" + (portfolioData.webUrl ?? "google.com")) else {
                print("url error")
                return
            }
            UIApplication.shared.open(chatURL, options: [:], completionHandler: nil)
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
            return isPreview ? imagePreviewDummy.count : imageArray.count
        case 2:
            return talentData.count
        case 3:
            return portfolioData.userPurposes.count
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
            if !isPreview {
                cell.portImageView.kfSetImage(url: imageArray[indexPath.row])
            } else {
                cell.portImageView.image = imagePreviewDummy[indexPath.row]
            }
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
            
            cell.talentLabel.text = talentData[indexPath.row].displayName.uppercased()
            cell.backgroundColor = talentData[indexPath.row].category.color
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfilePurposeCollectionViewCell.className,
                for: indexPath) as? ProfilePurposeCollectionViewCell else { return UICollectionViewCell() }
            cell.isTapped = true
            cell.config(num: isPreview ? portfolioData.userPurposes[indexPath.row] - 1 : portfolioData.userPurposes[indexPath.row])
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
            let totalItems = isPreview ? imagePreviewDummy.count : imageArray.count
            
            let collectionViewWidth = SizeLiterals.Screen.screenWidth - 34.adjustedWidth
            let spacing: CGFloat = 5.adjustedWidth
            
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

extension DetailProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, collectionView.tag == 0 {
            let pageWidth = scrollView.frame.width
            let currentPage = Int(scrollView.contentOffset.x / pageWidth)
            currentNum = currentPage
        }
    }
}
