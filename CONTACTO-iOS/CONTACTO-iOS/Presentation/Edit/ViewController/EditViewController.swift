//
//  EditViewController.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/7/24.
//

import UIKit

import Kingfisher
import PhotosUI
import SnapKit
import Then

final class EditViewController: UIViewController {
    
    private var originalPortfolioData: MyDetailResponseDTO?
    private var portfolioData = MyDetailResponseDTO(
        id: 0,
        username: "",
        description: "",
        instagramId: "",
        socialId: 0,
        loginType: "",
        email: "",
        nationality: "Other",
        webUrl: "",
        password: "",
        userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []),
        userPurposes: [],
        userTalents: []
    )

    private var talentData: [TalentInfo] = []
    
    var isEditEnable = false
    var tappedStates: [Bool] = Array(repeating: false, count: 5) {
        didSet {
            portfolioData.userPurposes = tappedStates.enumerated().compactMap { index, state in
                state ? index + 1 : nil
            }
            self.hasChanges()
        }
    }
    
    private var portfolioItems: [PortfolioItem] = []
    
    let activityIndicator = UIActivityIndicatorView(style: .large)

    private var activeTextField: UIView?
    
    var isTextFieldFilled = true {
        didSet {
            changeSaveButtonStatus()
        }
    }
    var isTextViewFilled = true {
        didSet {
            changeSaveButtonStatus()
        }
    }
    var isPortfolioFilled = true {
        didSet {
            changeSaveButtonStatus()
        }
    }
    var isPurposeFilled = true {
        didSet {
            changeSaveButtonStatus()
        }
    }
    var isDataChanged = false {
        didSet {
            changeSaveButtonStatus()
        }
    }
    
    let editView = EditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setData()
        setDelegate()
        setAddTarget()
        hideKeyboardWhenTappedAround()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        self.addKeyboardNotifications()
        if !isEditEnable {
            setData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
    // MARK: UI
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setStyle() { }
    
    private func setLayout() {
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        view.addSubviews(editView)
        
        editView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaHeight).offset(-tabBarHeight)
        }
    }
    
    private func setAddTarget() {
        editView.previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        editView.talentEditButton.addTarget(self, action: #selector(talentEditButtonTapped), for: .touchUpInside)
        editView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        editView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setClosure() {
        editView.editAction = {
            self.isEditEnable.toggle()
            let imageDataArray = self.portfolioItems.compactMap { $0.image?.jpegData(compressionQuality: 0.8) }
            if !self.isEditEnable {
                
                // (1) 이미지 관련 분류
                var newPortfolioImages: [Data] = []
                var existedImageUrl: [String] = []
                var newImageKeys: [Int] = []
                var existingImageKeys: [Int] = []
                
                for (index, item) in self.portfolioItems.enumerated() {
                    if item.isExistedSource {
                        if let urlString = item.url {
                            existedImageUrl.append(urlString)
                            existingImageKeys.append(index)
                        }
                    } else {
                        if let imgData = item.image?.jpegData(compressionQuality: 0.8) {
                            newPortfolioImages.append(imgData)
                            newImageKeys.append(index)
                        }
                    }
                }
                
                let body = EditRequestBodyDTO(
                    username: self.portfolioData.username,
                    email: self.portfolioData.email,
                    description: self.portfolioData.description,
                    instagramId: self.portfolioData.instagramId,
                    password: "",
                    webUrl: self.portfolioData.webUrl,
                    userPurposes: self.portfolioData.userPurposes.map { $0 - 1 },
                    userTalents: self.convertToTalent(displayNames: self.portfolioData.userTalents.map { $0.talentType }),
                    newPortfolioImages: newPortfolioImages.isEmpty ? nil : newPortfolioImages,
                    newImageKeys: newImageKeys.isEmpty ? nil : newImageKeys,
                    existedImageUrl: existedImageUrl.isEmpty ? nil : existedImageUrl,
                    existingImageKeys: existingImageKeys.isEmpty ? nil : existingImageKeys
                )
                self.editMyPort(bodyDTO: body) { _ in
                    self.editView.portfolioCollectionView.reloadData()
                    self.editView.purposeCollectionView.reloadData()
                    self.view.endEditing(true)
                }
            } else{
                self.editView.editButton.isEnabled = false
            }
        }
    }
    
    func convertToTalent(displayNames: [String]) -> [String] {
        return displayNames.compactMap { displayName in
            if let talent = Talent.allCases.first(where: { $0.info.displayName == displayName }) {
                return talent.rawValue
            } else {
                return nil
            }
        }
    }
    
    private func setDelegate() {
        editView.portfolioCollectionView.delegate = self
        editView.portfolioCollectionView.dataSource = self
        editView.talentCollectionView.delegate = self
        editView.talentCollectionView.dataSource = self
        editView.purposeCollectionView.delegate = self
        editView.purposeCollectionView.dataSource = self
        
        editView.descriptionTextView.delegate = self
        
        editView.nameTextField.delegate = self
        editView.instaTextField.delegate = self
        editView.websiteTextField.delegate = self
    }
    
    private func setCollectionView() {
        editView.portfolioCollectionView.register(EditPortfolioCollectionViewCell.self, forCellWithReuseIdentifier: EditPortfolioCollectionViewCell.className)
        editView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
        editView.purposeCollectionView.register(ProfilePurposeCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePurposeCollectionViewCell.className)
    }
    
    // MARK: - Server Function
    private func editMyPort(bodyDTO: EditRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        if !self.isEditEnable {
            NetworkService.shared.editService.editMyPort(bodyDTO: bodyDTO) { [weak self] response in
                switch response {
                case .success(let data):
                    completion(true)
                default:
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func checkMyPort(completion: @escaping (Bool) -> Void) {
        editView.editButton.isUserInteractionEnabled = false
        editView.previewButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        
        view.addSubview(activityIndicator)
        NetworkService.shared.editService.checkMyPort { [weak self] response in
            switch response {
            case .success(let data):
                self?.portfolioData = data
                self?.updatePortfolio()
                completion(true)
            default:
                completion(false)
            }
            
            self?.editView.editButton.isUserInteractionEnabled = true
            self?.editView.previewButton.isUserInteractionEnabled = true
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.removeFromSuperview()
        }
    }
    
    private func updatePortfolio() {
        self.portfolioItems.removeAll()

        editView.nameTextField.text = portfolioData.username
        editView.descriptionTextView.text = portfolioData.description
        editView.instaTextField.text = portfolioData.instagramId
        if let web = portfolioData.webUrl {
            editView.websiteTextField.text = web
        }
        
        let existingUrls = portfolioData.userPortfolio?.portfolioImageUrl ?? []
        existingUrls.forEach { urlString in
            let item = PortfolioItem(isExistedSource: true, url: urlString, image: nil)
            self.portfolioItems.append(item)
        }
        
        talentData = portfolioData.userTalents.compactMap { userTalent in
            Talent.allCases.first(where: { $0.info.koreanName == userTalent.talentType })?.info
        }

        portfolioData.userTalents = talentData.map { talentInfo in
            UserTalent(id: 0, userId: portfolioData.id, talentType: talentInfo.displayName)
        }
        
        let dispatchGroup = DispatchGroup()
        
        for (index, urlString) in existingUrls.enumerated() {
            guard let imageUrl = URL(string: urlString) else { continue }
            dispatchGroup.enter()
            
            KingfisherManager.shared.downloader.downloadImage(with: imageUrl) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        if index < self.portfolioItems.count {
                            self.portfolioItems[index].image = value.image
                        }
                    }
                case .failure(let error):
                    #if DEBUG
                    print("Failed to load image: \(error.localizedDescription)")
                    #endif
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.editView.portfolioCollectionView.reloadData()
        }
        
        portfolioData.userPurposes.forEach { index in
            if index < tappedStates.count {
                tappedStates[index] = true
            }
        }
        
        editView.talentCollectionView.reloadData()
        editView.purposeCollectionView.reloadData()
    }
    
    private func setData() {
        self.checkMyPort { _ in
            self.originalPortfolioData = self.portfolioData
            self.checkTalentLayout()
        }
    }
    
    private func checkTalentLayout() {
        editView.talentCollectionView.layoutIfNeeded()
        
        editView.talentCollectionView.snp.remakeConstraints {
            $0.top.equalTo(editView.talentLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(editView.talentCollectionView.contentSize.height + 4)
        }
    }
    
    func setPortfolio() {
        var configuration = PHPickerConfiguration()
        lazy var picker = PHPickerViewController(configuration: configuration)
        configuration.selectionLimit = 10 - portfolioItems.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
    
    private func hasChanges() {
        guard let originalData = originalPortfolioData else { 
            isDataChanged = true
            return
        }

        var changeDetected = portfolioData.username != originalData.username ||
            portfolioData.description != originalData.description ||
            portfolioData.instagramId != originalData.instagramId ||
            portfolioData.webUrl != originalData.webUrl ||
            portfolioData.userPurposes.sorted() != originalData.userPurposes.sorted() ||
            portfolioData.userTalents.map({ $0.talentType }).sorted() != originalData.userTalents.map({ $0.talentType }).sorted()
        
        // 비동기적으로 로드
        let originalURLs = originalData.userPortfolio?.portfolioImageUrl.compactMap { URL(string: $0) } ?? []
        var originalImageData = [Data]()
        let group = DispatchGroup()
        
        for url in originalURLs {
            group.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    originalImageData.append(data)
                }
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            let selectedImageData = self.portfolioItems.compactMap { $0.image?.pngData() }
            // 이미지 데이터의 변경 여부도 포함하여 최종적으로 변경 여부를 결정
            changeDetected = changeDetected || (selectedImageData != originalImageData)
            self.isDataChanged = changeDetected
        }
    }
    
    private func changeSaveButtonStatus() {
        if isTextFieldFilled,
           isTextViewFilled,
           isPortfolioFilled,
           isPurposeFilled,
           isDataChanged {
            editView.editButton.isEnabled = true
        } else {
            editView.editButton.isEnabled = false
        }
    }
    
    private func addKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification) {
        guard let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 85
        
        let bottomInset = keyboardHeight - tabBarHeight - 35.adjustedHeight

        editView.scrollView.contentInset.bottom = bottomInset
        editView.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        
        self.editView.editButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight + 13.adjustedHeight)
            $0.leading.equalTo(self.editView.cancelButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        self.editView.cancelButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight + 13.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(self.editView.cancelButton.snp.height)
            $0.leading.equalToSuperview().inset(16)
        }
        
        if let activeField = activeTextField {
            if activeField.frame.minY > (view.frame.height - keyboardHeight) {
                let yOffset = activeField.frame.maxY - (view.frame.height + tabBarHeight - keyboardHeight) + 45.adjustedHeight
                editView.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardHeight + yOffset), animated: false)
            }
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        
        editView.scrollView.contentInset.bottom = 0
        editView.scrollView.verticalScrollIndicatorInsets.bottom = 0
        
        self.editView.editButton.snp.remakeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
            if isEditEnable {
                $0.leading.equalTo(self.editView.cancelButton.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(16)
            } else {
                $0.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        self.editView.cancelButton.snp.remakeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(self.editView.cancelButton.snp.height)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
        
        if let activeField = activeTextField {
            if activeField == editView.instaTextField || activeField == editView.websiteTextField {
                editView.scrollView.setContentOffset(CGPoint(x: 0,
                                                             y: editView.scrollView.contentSize.height - editView.scrollView.bounds.height),
                                                     animated: true)
            }
        }
        
        self.view.layoutIfNeeded()
    }
}

extension EditViewController {
    @objc private func previewButtonTapped() {
        let previewViewController = HomeViewController()
        previewViewController.isPreview = true
        previewViewController.previewPortfolioData = self.portfolioData
        previewViewController.imagePreviewDummy = portfolioItems.compactMap { $0.image }
        previewViewController.previewPortfolioData.userTalents = []
        self.talentData.forEach {
            previewViewController.previewPortfolioData.userTalents.append(
                UserTalent(id: 0, userId: self.portfolioData.id, talentType: $0.displayName)
            )
        }
        let navigationController = UINavigationController(rootViewController: previewViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func talentEditButtonTapped() {
        let talentViewController = TalentOnboardingViewController()
        talentViewController.hidesBottomBarWhenPushed = true
        talentViewController.talentOnboardingView.nextButton.setTitle(StringLiterals.Edit.doneButton, for: .normal)
        talentViewController.isEdit = true
        talentViewController.editTalent = talentData
        talentViewController.updateTalent = {
            self.talentData = talentViewController.editTalent
            self.editView.talentCollectionView.reloadData()
            var talents: [UserTalent] = []
            self.talentData.forEach {
                talents.append(
                    UserTalent(id: 0, userId: self.portfolioData.id, talentType: $0.displayName)
                )
            }
            self.portfolioData.userTalents = talents
            self.checkTalentLayout()
            self.hasChanges()
        }
        navigationController?.pushViewController(talentViewController, animated: true)
    }
}

extension EditViewController: UICollectionViewDelegate { }

extension EditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 10
        case 1:
            return talentData.count
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
            if indexPath.row < portfolioItems.count {
                let item = portfolioItems[indexPath.row]
                cell.isFilled = true
                cell.backgroundImageView.image = item.image
            } else {
                cell.isFilled = false
                cell.backgroundImageView.image = nil
            }
            
            cell.uploadAction = {
                self.setPortfolio()
            }
            
            cell.cancelAction = {
                guard indexPath.row < self.portfolioItems.count else { return }
                self.portfolioItems.remove(at: indexPath.row)
                self.isPortfolioFilled = !self.portfolioItems.isEmpty
                collectionView.reloadData()
                
                self.hasChanges()
            }
            
            cell.backgroundButton.isEnabled = isEditEnable
            cell.cancelButton.isEnabled = isEditEnable
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfileTalentCollectionViewCell.className,
                for: indexPath) as? ProfileTalentCollectionViewCell else { return UICollectionViewCell() }
            
            cell.talentLabel.text = talentData[indexPath.row].displayName.uppercased()
            cell.backgroundColor = talentData[indexPath.row].category.color
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProfilePurposeCollectionViewCell.className,
                for: indexPath) as? ProfilePurposeCollectionViewCell else { return UICollectionViewCell() }
            cell.isTapped = tappedStates[indexPath.row]
            cell.config(num: indexPath.item)
            cell.isEditing = isEditEnable
            cell.setAddTarget()
            cell.tapAction = {
                self.tappedStates[indexPath.row] = cell.isTapped
                self.isPurposeFilled = self.tappedStates.contains(true)
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension EditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let group = DispatchGroup()
        
        var pickedImages: [UIImage] = []
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                defer { group.leave() }
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        pickedImages.append(image)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            for image in pickedImages {
                let newItem = PortfolioItem(isExistedSource: false, url: nil, image: image)
                self.portfolioItems.append(newItem)
            }
            
            self.isPortfolioFilled = !self.portfolioItems.isEmpty
            self.editView.portfolioCollectionView.reloadData()
            
            self.hasChanges()
        }
    }
}

extension EditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextField = nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty || !textView.text.isOnlyWhitespace() {
            self.isTextViewFilled = true
        } else {
            self.isTextViewFilled = false
        }
        if let text = textView.text {
            self.portfolioData.description = text
        }
        
        hasChanges()
    }
    
    // 입력값을 검증하고 결과를 ValidationResult로 반환
    private func validateInputs() -> ValidationResult {
        // 이름 검증: 공백 제거 후, 2-20자의 영문자, 숫자, 한글만 허용
        guard let name = editView.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return ValidationResult(isValid: false, message: "이름이 비어있습니다.")
        }
        let nameRegex = "^[a-zA-Z0-9가-힣]{2,20}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !nameTest.evaluate(with: name) {
            return ValidationResult(isValid: false, message: "이름은 2-20자의 영문자, 숫자, 한글만 가능합니다.")
        }
        
        // website URL 검증: 값이 있다면 http:// 또는 https:// 로 시작해야 함
        if let website = editView.websiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !website.isEmpty {
            if !(website.hasPrefix("http://") || website.hasPrefix("https://")) {
                return ValidationResult(isValid: false, message: "website URL은 http:// 또는 https:// 로 시작해야 합니다.")
            }
        }
        
        // purpose 검증: portfolioData.userPurposes 배열은 비어있으면 안 됨
        if portfolioData.userPurposes.isEmpty {
            return ValidationResult(isValid: false, message: "Purpose 항목이 선택되지 않았습니다.")
        }
        
        // talent 검증: portfolioData.userTalents 배열은 비어있으면 안 됨
        if portfolioData.userTalents.isEmpty {
            return ValidationResult(isValid: false, message: "Talent 항목이 선택되지 않았습니다.")
        }
        
        // portfolio 검증: 선택된 이미지 배열은 비어있으면 안 됨
        if portfolioItems.isEmpty {
            return ValidationResult(isValid: false, message: "Portfolio 이미지를 선택해야 합니다.")
        }
        
        // 모든 검증 통과
        return ValidationResult(isValid: true, message: nil)
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField != editView.websiteTextField  {
            if let text = textField.text {
                if !text.isEmpty || !text.isOnlyWhitespace() {
                    self.isTextFieldFilled = true
                } else {
                    self.isTextFieldFilled = false
                }
            }
        }
        
        if let text = textField.text {
            switch textField {
            case editView.nameTextField:
                self.portfolioData.username = text
            case editView.instaTextField:
                self.portfolioData.instagramId = text
            case editView.websiteTextField:
                self.portfolioData.webUrl = text
            default:
                print("default")
            }
        }
        
        hasChanges()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc private func cancelButtonTapped() {
        isEditEnable.toggle()
        editView.toggleEditMode(isEditEnable)
        // 데이터 초기화
        portfolioItems.removeAll()
        setData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tappedStates = Array(repeating: false, count: 5)
            self.portfolioData.userPurposes.forEach { index in
                if index < self.tappedStates.count {
                    self.tappedStates[index] = true
                }
            }
            self.editView.purposeCollectionView.reloadData()
        }
        self.view.layoutIfNeeded()
    }
    
    // 수정 버튼 액션
    @objc private func editButtonTapped() {
        // 편집 모드 토글
        isEditEnable.toggle()
        editView.toggleEditMode(isEditEnable)
        
        if !isEditEnable {
            let isValidProfile = validateInputs()
            if isValidProfile.isValid == false {
                AlertManager.showAlert(on: self,
                                       message: isValidProfile.message ?? "입력값에 오류가 있습니다.") {
                    self.isEditEnable = true
                    self.editView.toggleEditMode(self.isEditEnable)
                }
                return
            }
            
            var newPortfolioImages: [Data] = []
            var existedImageUrl: [String] = []
            var newImageKeys: [Int] = []
            var existingImageKeys: [Int] = []
            
            for (index, item) in portfolioItems.enumerated() {
                if item.isExistedSource {
                    if let url = item.url {
                        existedImageUrl.append(url)
                        existingImageKeys.append(index)
                    }
                } else {
                    if let imgData = item.image?.jpegData(compressionQuality: 0.8) {
                        newPortfolioImages.append(imgData)
                        newImageKeys.append(index)
                    }
                }
            }
            
            // 검증이 통과된 경우 백엔드 요청 전송
            let body = EditRequestBodyDTO(
                username: portfolioData.username.trimmingCharacters(in: .whitespacesAndNewlines),
                email: portfolioData.email,
                description: portfolioData.description,
                instagramId: portfolioData.instagramId,
                password: "",
                webUrl: portfolioData.webUrl,
                userPurposes: portfolioData.userPurposes.map { $0 - 1 },
                userTalents: convertToTalent(displayNames: portfolioData.userTalents.map { $0.talentType }),
                newPortfolioImages: newPortfolioImages.isEmpty ? nil : newPortfolioImages,
                newImageKeys: newImageKeys.isEmpty ? nil : newImageKeys,
                existedImageUrl: existedImageUrl.isEmpty ? nil : existedImageUrl,
                existingImageKeys: existingImageKeys.isEmpty ? nil : existingImageKeys
            )
            
            editMyPort(bodyDTO: body) { success in
                if success {
                    self.editView.portfolioCollectionView.reloadData()
                    self.editView.purposeCollectionView.reloadData()
                    self.view.endEditing(true)
                    self.isDataChanged = false
                    self.editView.editButton.isEnabled = true
                }
            }
        } else {
            // 편집 모드 진입 시 저장 버튼 비활성화
            editView.editButton.isEnabled = false
        }
        
        editView.portfolioCollectionView.reloadData()
        editView.purposeCollectionView.reloadData()
    }
}
