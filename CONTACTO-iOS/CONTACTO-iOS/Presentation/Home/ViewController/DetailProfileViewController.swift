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
    var userId = 0
    var isPreview = false
    var isFromChat = false
    
    let detailProfileView = DetailProfileView()
    var portfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", nationality: Nationalities.NONE, webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []), userPurposes: [], userTalents: [])
    private var talentData: [TalentInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_BACK)
    }
    
    override func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func setLayout() {
        view.addSubviews(detailProfileView)

        detailProfileView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            
            if isFromChat {
                $0.bottom.leading.trailing.equalToSuperview()
            } else {
                let safeAreaHeight = view.safeAreaInsets.bottom
                let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
                $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
            }
        }
    }
    
    override func setAddTarget() {
        detailProfileView.popButton.addTarget(self, action: #selector(popButtonTapped), for: .touchUpInside)
        detailProfileView.instaButton.addTarget(self, action: #selector(instaButtonTapped), for: .touchUpInside)
        detailProfileView.webButton.addTarget(self, action: #selector(webButtonTapped), for: .touchUpInside)
        detailProfileView.blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        detailProfileView.reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
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
        detailProfileView.scrollView.delegate = self
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
                    completion(true)
                default:
                    completion(false)
                }
            }
        } else {
            self.updatePortfolio()
        }
        completion(true)
    }
    
    private func blockUser(blockedUserId: Int, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.blockUser(blockedUserId: portfolioData.id) { response in
            switch response {
            case .success(let data):
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            
            }
        }
    }
    
    private func reportUser(bodyDTO: ReportRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.homeService.reportUser(bodyDTO: bodyDTO) { response in
            switch response {
            case .success(let data):
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            
            }
        }
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
        if let webUrl = self.portfolioData.webUrl, !webUrl.isEmpty {
            self.detailProfileView.webButton.isHidden = false
        } else {
            self.detailProfileView.webButton.isHidden = true
        }
        
        self.detailProfileView.talentCollectionView.reloadData()
        self.detailProfileView.purposeCollectionView.reloadData()
        
        // 레이아웃이 완료된 후에 높이 계산
        DispatchQueue.main.async {
            self.resetCollectionViewLayout()
        }
    }
    
    private func setData() {
        if isPreview {
            self.detailProfileView.blockButton.isEnabled = false
            self.detailProfileView.reportButton.isEnabled = false
        }
        detailPort(userId: userId) { _ in }
    }
    
    private func resetCollectionViewLayout() {
        self.detailProfileView.talentCollectionView.layoutIfNeeded()
        self.detailProfileView.purposeCollectionView.layoutIfNeeded()
        
        let talentHeight = self.detailProfileView.talentCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.detailProfileView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(self.detailProfileView.nameLabel.snp.bottom).offset(17)
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(13)
            $0.height.equalTo(talentHeight + 10)
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
        detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_INSTA)
    }
    
    @objc private func webButtonTapped() {
        guard let url = URL(string: portfolioData.webUrl ?? "google.com") else {
            let alert = UIAlertController(title: "에러", message: "url error", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            guard let chatURL = URL(string: "https://" + (portfolioData.webUrl ?? "google.com")) else {
                let alert = UIAlertController(title: "에러", message: "url error", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true, completion: nil)
                return
            }
            UIApplication.shared.open(chatURL, options: [:], completionHandler: nil)
        }
        detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_WEB)
    }
    
    @objc private func popButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func blockButtonTapped() {
        guard !isPreview else { return }
        
        let alert = UIAlertController(
            title: StringLiterals.Home.Block.title,
            message: StringLiterals.Home.Block.message,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_BLOCK_NO)
        }
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { _ in
            self.detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_BLOCK_YES)
            self.blockUser(blockedUserId: self.portfolioData.id) { success in
                DispatchQueue.main.async {
                    if success {
                        let successAlert = UIAlertController(
                            title: nil,
                            message: StringLiterals.Home.Block.result,
                            preferredStyle: .alert
                        )
                        if let navigationController = self.navigationController {
                            navigationController.popViewController(animated: true)
                        }
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        successAlert.addAction(okAction)
                        self.present(successAlert, animated: true, completion: nil)
                    } else {
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "사용자 차단에 실패했습니다.",
                            preferredStyle: .alert
                        )
                        if let navigationController = self.navigationController {
                            navigationController.popViewController(animated: true)
                        }
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        errorAlert.addAction(okAction)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        alert.addAction(blockAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func reportButtonTapped() {
        let alert = UIAlertController(title: StringLiterals.Home.Report.title, message: nil, preferredStyle: .actionSheet)
        
        let reportReasons = StringLiterals.Home.Report.ReportReasons.allCases
        for (index, reason) in reportReasons.enumerated() {
            let action = UIAlertAction(title: reason, style: .default) { _ in
                print("User reported for reason at index \(index): \(reason)")
                self.reportUser(bodyDTO: ReportRequestBodyDTO(reportedUserId: self.portfolioData.id, reportReasonIdx: index)) { success in
                    DispatchQueue.main.async {
                        if success {
                            let successAlert = UIAlertController(
                                title: nil,
                                message: StringLiterals.Home.Report.result,
                                preferredStyle: .alert
                            )
                            let okAction = UIAlertAction(title: "OK", style: .default)
                            successAlert.addAction(okAction)
                            self.present(successAlert, animated: true, completion: nil)
                        } else {
                            let errorAlert = UIAlertController(
                                title: "Error",
                                message: "신고 처리에 실패했습니다.",
                                preferredStyle: .alert
                            )
                            let okAction = UIAlertAction(title: "OK", style: .default)
                            errorAlert.addAction(okAction)
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                    }
                }
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        detailProfileView.sendAmpliLog(eventName: EventName.CLICK_DETAIL_REPORT_NO)
        present(alert, animated: true, completion: nil)
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
            cell.config(num: isPreview ? portfolioData.userPurposes[indexPath.row] : portfolioData.userPurposes[indexPath.row])
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
            let talent = talentData[indexPath.row].displayName.uppercased()
            let font = UIFont.systemFont(ofSize: 12, weight: .medium)
            let attributes = [NSAttributedString.Key.font: font]
            let textSize = (talent as NSString).size(withAttributes: attributes)
            return CGSize(width: textSize.width + 16, height: 19)
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
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        detailProfileView.sendAmpliLog(eventName: EventName.SCROLL_DETAIL)
    }
}
