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

// TODO: - put 확인 (500 확인)
final class EditViewController: UIViewController {
    
    private var originalPortfolioData: MyDetailResponseDTO?
    private var portfolioData = MyDetailResponseDTO(id: 0, username: "", description: "", instagramId: "", socialId: 0, loginType: "", email: "", webUrl: nil, password: "", userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImageUrl: []), userPurposes: [], userTalents: [])
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
    
    var selectedImages: [UIImage] = []
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
            let imageDataArray = self.selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
            
            let body = EditRequestBodyDTO(
                username: self.portfolioData.username,
                email: self.portfolioData.email,
                description: self.portfolioData.description,
                instagramId: self.portfolioData.instagramId,
                password: "",
                webUrl: self.portfolioData.webUrl,
                userPurposes: self.portfolioData.userPurposes.map { $0 - 1 },
                userTalents: self.convertToTalent(displayNames: self.portfolioData.userTalents.map { $0.talentType }),
                                portfolioImageUrl: imageDataArray)
            self.editMyPort(bodyDTO: body) { _ in
                self.editView.portfolioCollectionView.reloadData()
                self.editView.purposeCollectionView.reloadData()
                self.view.endEditing(true)
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
                    print(data)
                    completion(true)
                default:
                    completion(false)
                    print("error")
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
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            }
            
            self?.editView.editButton.isUserInteractionEnabled = true
            self?.editView.previewButton.isUserInteractionEnabled = true
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.removeFromSuperview()
        }
    }
    
    private func updatePortfolio() {
        selectedImages.removeAll()
        editView.nameTextField.text = portfolioData.username
        editView.descriptionTextView.text = portfolioData.description
        editView.instaTextField.text = portfolioData.instagramId
        if let web = portfolioData.webUrl {
            editView.websiteTextField.text = web
        }
        
        talentData = portfolioData.userTalents.compactMap { userTalent in
            Talent.allCases.first(where: { $0.info.koreanName == userTalent.talentType })?.info
        }
        
        let dispatchGroup = DispatchGroup()
        
        portfolioData.userPortfolio?.portfolioImageUrl.forEach { url in
            guard let imageUrl = URL(string: url) else { return }
            
            dispatchGroup.enter() // 작업 시작
            KingfisherManager.shared.downloader.downloadImage(with: imageUrl) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        if !(self.selectedImages.contains(value.image)) {
                            self.selectedImages.append(value.image)
                        }
                    }
                case .failure(let error):
                    print("Failed to load image: \(error.localizedDescription)")
                }
                dispatchGroup.leave() // 작업 완료
            }
        }
        
        // 모든 작업이 완료된 후 실행
        dispatchGroup.notify(queue: .main) {
            print(self.selectedImages)
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
            self.originalPortfolioData = self.portfolioData // 원본 데이터 저장
            print("원본 데이터: \(String(describing: self.originalPortfolioData))")
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
        configuration.selectionLimit = 10 - selectedImages.count
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        self.present(picker, animated: true, completion: nil)
        picker.delegate = self
    }
    
    private func hasChanges() {
        guard let originalData = originalPortfolioData else { 
            isDataChanged = true
            return
        } // 원본 데이터가 없으면 변경된 것으로 간주

        isDataChanged = (
            portfolioData.username != originalData.username ||
            portfolioData.description != originalData.description ||
            portfolioData.instagramId != originalData.instagramId ||
            portfolioData.webUrl != originalData.webUrl ||
            selectedImages.map { $0.pngData() }.compactMap { $0 } != originalData.userPortfolio?.portfolioImageUrl.compactMap { URL(string: $0) }.compactMap { try? Data(contentsOf: $0) } ||
            portfolioData.userPurposes.sorted() != originalData.userPurposes.sorted() ||
            portfolioData.userTalents.map({ $0.talentType }).sorted() != originalData.userTalents.map({ $0.talentType }).sorted()
        )
    }
    
    private func changeSaveButtonStatus() {
        print("textField:\(isTextFieldFilled)\ntextView:\(isTextViewFilled)\nportfolio:\(isPortfolioFilled)\npurpose:\(isPurposeFilled)\neditEnabled:\(isEditEnable)")
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
        
        // 현재 활성화된 텍스트 필드가 있는지 확인
        if let activeField = activeTextField {
            print(activeField)
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
        previewViewController.imagePreviewDummy = selectedImages
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
            print(selectedImages.count) 
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
                self.isPortfolioFilled = !self.selectedImages.isEmpty
                collectionView.reloadData()
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
        var addedImages: [UIImage?] = Array(repeating: nil, count: results.count)
        let group = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        if !self.selectedImages.contains(where: { $0.isEqualTo(image) }), self.selectedImages.count < 10  {
                            addedImages[index] = image
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let newImages = addedImages.compactMap { $0 }
            self.selectedImages.append(contentsOf: newImages)
            self.isPortfolioFilled = !self.selectedImages.isEmpty
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
        selectedImages.removeAll()
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
    
    @objc private func editButtonTapped() {
        isEditEnable.toggle()
        editView.toggleEditMode(isEditEnable)
        
        if isEditEnable {
            editView.editButton.isEnabled = false
        } else {
            let imageDataArray = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
            let body = EditRequestBodyDTO(
                username: portfolioData.username,
                email: portfolioData.email,
                description: portfolioData.description,
                instagramId: portfolioData.instagramId,
                password: "",
                webUrl: portfolioData.webUrl,
                userPurposes: portfolioData.userPurposes.map { $0 - 1 },
                userTalents: convertToTalent(displayNames: portfolioData.userTalents.map { $0.talentType }),
                portfolioImageUrl: imageDataArray
            )
            
            editMyPort(bodyDTO: body) { _ in
                self.editView.portfolioCollectionView.reloadData()
                self.editView.purposeCollectionView.reloadData()
                self.view.endEditing(true)
            }
            
            self.isDataChanged = false
            self.editView.editButton.isEnabled = true
        }
        
        editView.portfolioCollectionView.reloadData()
        editView.purposeCollectionView.reloadData()
    }
}
