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

final class EditViewController: UIViewController, EditAmplitudeSender, CropImageViewControllerDelegate {
    
    private var portfolioManager: PortfolioManager?
    
    private var originalPortfolioData: MyDetailResponseDTO?
    
    private var talentData: [TalentInfo] = []
    
    var isEditEnable = false
    
    private var changeDetectionTimer: Timer?
    
    private var isFromTalentVC = false
    
    // 탭 이동 시 수정 상태 유지를 위한 변수
    private var wasEditEnabled = false
    
    private func scheduleChangeDetection() {
        changeDetectionTimer?.invalidate()
        changeDetectionTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] _ in
            self?.portfolioManager?.hasChanges { changeDetected in
                DispatchQueue.main.async {
                    self?.isDataChanged = changeDetected
                }
            }
        }
    }
    
    private var lastScrollLogTime: Date?
    private let scrollLogInterval: TimeInterval = 3.0
    private var isInitializing: Bool = true
    private let serialQueue = DispatchQueue(label: "com.contacto.pendingImages")
    
    var tappedStates: [Bool] = Array(repeating: false, count: 5) {
        didSet {
            self.portfolioManager?.currentData.userPurposes = tappedStates.enumerated().compactMap { index, state in
                state ? index : nil
            }
            scheduleChangeDetection()
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var activeTextField: UIView?
    
    var isTextFieldFilled = true {
        didSet { changeSaveButtonStatus() }
    }
    var isTextViewFilled = true {
        didSet { changeSaveButtonStatus() }
    }
    var isPortfolioFilled = true {
        didSet { changeSaveButtonStatus() }
    }
    var isPurposeFilled = true {
        didSet { changeSaveButtonStatus() }
    }
    var isDataChanged = false {
        didSet { changeSaveButtonStatus() }
    }
    
    var isNationalitySelected = true {
        didSet { changeSaveButtonStatus() }
    }
    
    let editView = EditView()
    
    private let countries = Nationalities.allCases
    
    private var pendingImages: [UIImage] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setDelegate()
        setAddTarget()
        hideKeyboardWhenTappedAround()
        setCollectionView()
        setPickerDelegate()
        
        // user_id 설정
        if let userId = portfolioManager?.currentData.id {
            UserDefaults.standard.set(String(userId), forKey: "userId")
        }
        
        if let username = portfolioManager?.currentData.username {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sendAmpliLog(eventName: EventName.VIEW_EDIT)
        setNavigationBar()
        addKeyboardNotifications()
        if !isFromTalentVC {
            if wasEditEnabled {
                // 탭 이동 후 복귀 시 이전 수정 모드 상태 복원
                isEditEnable = true
                editView.toggleEditMode(true)
                wasEditEnabled = false
            } else {
                // 최초 로드 또는 수정 모드가 아니었던 경우
                isEditEnable = false
                editView.toggleEditMode(false)
                setData()
            }
        }
        isFromTalentVC = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotifications()
        
        // 탭 전환 시 수정 모드 상태 저장
        if isEditEnable {
            wasEditEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isInitializing = false
    }
    
    // MARK: - UI Setup
    private func setUI() {
        setStyle()
        setLayout()
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.isHidden = true
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editProfileLabelTapped))
        editView.editLabel.isUserInteractionEnabled = true
        editView.editLabel.addGestureRecognizer(tapGesture)
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
        editView.nationalityTextField.delegate = self
        
        editView.scrollView.delegate = self
    }
    
    private func setCollectionView() {
        editView.portfolioCollectionView.register(EditPortfolioCollectionViewCell.self, forCellWithReuseIdentifier: EditPortfolioCollectionViewCell.className)
        editView.talentCollectionView.register(ProfileTalentCollectionViewCell.self, forCellWithReuseIdentifier: ProfileTalentCollectionViewCell.className)
        editView.purposeCollectionView.register(ProfilePurposeCollectionViewCell.self, forCellWithReuseIdentifier: ProfilePurposeCollectionViewCell.className)
    }
    
    private func setPickerDelegate() {
        editView.nationalityPicker.delegate = self
        editView.nationalityPicker.dataSource = self
    }
    
    // MARK: - Server Functionality
    private func editMyPort(bodyDTO: EditRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        if !isEditEnable {
            NetworkService.shared.editService.editMyPort(bodyDTO: bodyDTO) { response in
                switch response {
                case .success:
                    UserIdentityManager.updateDetailProperty(data: bodyDTO)
                    completion(true)
                case .failure(let error):
                    if error.statusCode == 409 {
                        AlertManager.showAlert(on: self,
                                               message: StringLiterals.Edit.duplicateUserName) {
                            self.isEditEnable = true
                            self.editView.toggleEditMode(self.isEditEnable)
                        }
                    }
                    completion(false)
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
            guard let self = self else { return }
            switch response {
            case .success(let data):
                self.portfolioManager = PortfolioManager(portfolioData: data)
                self.portfolioManager?.updatePortfolioItems {
                    self.editView.portfolioCollectionView.reloadData()
                }
                self.originalPortfolioData = data
                self.checkTalentLayout()
                self.updateUI()
                completion(true)
            default:
                completion(false)
            }
            
            self.editView.editButton.isUserInteractionEnabled = true
            self.editView.previewButton.isUserInteractionEnabled = true
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    // MARK: - Data Setup
    private func setData() {
        self.checkMyPort { _ in
            self.checkTalentLayout()
            self.updateUI()
        }
    }
    
    private func updateUI() {
        guard let manager = portfolioManager else { return }
        editView.nameTextField.text = manager.currentData.username
        editView.descriptionTextView.text = manager.currentData.description
        editView.instaTextField.text = manager.currentData.instagramId
        editView.websiteTextField.text = manager.currentData.webUrl
        
        let currentNationality = Nationalities(rawValue: (manager.currentData.nationality ?? Nationalities.NONE).rawValue) ?? .NONE
        editView.nationalityTextField.text = currentNationality.displayName
        isNationalitySelected = currentNationality != Nationalities.NONE
        
        if let index = countries.firstIndex(of: currentNationality) {
            editView.nationalityPicker.selectRow(index, inComponent: 0, animated: false)
        }
        
        self.talentData = manager.currentData.userTalents.compactMap { userTalent in
            return Talent.allCases.first(where: { $0.info.koreanName == userTalent.talentType || $0.info.displayName == userTalent.talentType })?.info
        }
        editView.talentCollectionView.reloadData()
        
        var newTappedStates = Array(repeating: false, count: 5)
        for purpose in manager.currentData.userPurposes {
            let index = purpose
            if index >= 0 && index < newTappedStates.count {
                newTappedStates[index] = true
            }
        }
        self.tappedStates = newTappedStates
        editView.purposeCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.editView.purposeCollectionView.layoutIfNeeded()
            self.editView.purposeCollectionView.snp.updateConstraints {
                $0.height.equalTo(self.editView.purposeCollectionView.contentSize.height)
            }
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
    
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage) {
        let screenSize = UIScreen.main.bounds.size
        let targetSize = CGSize(
            width: screenSize.width * 1.5,
            height: screenSize.height * 1.5
        )
        
        let resizedImage: UIImage
        if image.needsResizing(targetSize: targetSize),
           let tempResizedImage = image.resized(to: targetSize) {
            resizedImage = tempResizedImage
        } else {
            resizedImage = image
        }
        
        addPortfolioItem(image: resizedImage)
    }
    
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController) {
        // 크롭 취소 시 이미지 선택 화면으로 돌아가기
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.setPortfolio()
        }
    }
    
    private func addPortfolioItem(image: UIImage) {
        guard let manager = self.portfolioManager else { return }
        let newItem = PortfolioItem(isExistedSource: false, url: nil, image: image)
        manager.portfolioItems.append(newItem)
        
        self.isPortfolioFilled = !(manager.portfolioItems.isEmpty)
        self.editView.portfolioCollectionView.reloadData()
        self.checkForChanges()
    }
    
    func setPortfolio() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10 - (portfolioManager?.portfolioItems.count ?? 0)
        configuration.filter = .any(of: [.images])
        configuration.selection = .ordered
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Change Detection
    private func checkForChanges() {
        portfolioManager?.hasChanges { [weak self] changeDetected in
            self?.isDataChanged = changeDetected
        }
    }
    
    private func changeSaveButtonStatus() {
        if isTextFieldFilled,
           isTextViewFilled,
           isPortfolioFilled,
           isPurposeFilled,
           isNationalitySelected {
            editView.editButton.isEnabled = true
        } else {
            editView.editButton.isEnabled = false
        }
    }
    
    // MARK: - Keyboard Notifications
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
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
        
        editView.editButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight + 13.adjustedHeight)
            $0.leading.equalTo(editView.cancelButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        editView.cancelButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight + 13.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(editView.cancelButton.snp.height)
            $0.leading.equalToSuperview().inset(16)
        }
        
        if let activeField = activeTextField,
           activeField.frame.minY > (view.frame.height - keyboardHeight) {
            let yOffset = activeField.frame.maxY - (view.frame.height + tabBarHeight - keyboardHeight) + 45.adjustedHeight
            editView.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardHeight + yOffset), animated: false)
        }
        
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        editView.scrollView.contentInset.bottom = 0
        editView.scrollView.verticalScrollIndicatorInsets.bottom = 0
        
        editView.editButton.snp.remakeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
            if isEditEnable {
                $0.leading.equalTo(editView.cancelButton.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(16)
            } else {
                $0.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        editView.cancelButton.snp.remakeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(editView.cancelButton.snp.height)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
        
        if let activeField = activeTextField,
           activeField == editView.instaTextField || activeField == editView.websiteTextField {
            editView.scrollView.setContentOffset(CGPoint(x: 0,
                                                         y: editView.scrollView.contentSize.height - editView.scrollView.bounds.height),
                                                 animated: true)
        }
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Button Actions
    @objc private func previewButtonTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_EDIT_PREVIEW)
        let previewVC = HomeViewController(isPreview: true)

        if let manager = portfolioManager {
            previewVC.currentUserId = manager.currentData.id
            previewVC.previewPortfolioData = manager.currentData
            previewVC.previewImages = manager.portfolioItems.compactMap { $0.image }
            previewVC.portfolioImageIdx = 0
            previewVC.homeView.portImageView.image = previewVC.previewImages[previewVC.portfolioImageIdx]
            previewVC.previewPortfolioData.userTalents = []
            self.talentData.forEach {
                previewVC.previewPortfolioData.userTalents.append(
                    UserTalent(id: 0, userId: manager.currentData.id, talentType: $0.displayName)
                )
            }
        }
        let navController = UINavigationController(rootViewController: previewVC)
        present(navController, animated: true)
    }
    
    @objc private func talentEditButtonTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_EDIT_TALENT)
        let talentVC = TalentOnboardingViewController()
        talentVC.hidesBottomBarWhenPushed = true
        talentVC.talentOnboardingView.nextButton.setTitle(StringLiterals.Edit.doneButton, for: .normal)
        talentVC.isEdit = true
        talentVC.editTalent = talentData
        talentVC.updateTalent = { [weak self] in
            guard let self = self else { return }
            self.talentData = talentVC.editTalent
            self.editView.talentCollectionView.reloadData()
            var talents: [UserTalent] = []
            self.talentData.forEach {
                talents.append(UserTalent(id: 0, userId: self.portfolioManager?.currentData.id ?? 0, talentType: $0.displayName))
            }
            self.portfolioManager?.currentData.userTalents = talents
            self.checkTalentLayout()
            self.checkForChanges()
        }
        isFromTalentVC = true
        navigationController?.pushViewController(talentVC, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        isEditEnable.toggle()
        editView.toggleEditMode(isEditEnable)
        portfolioManager = nil
        setData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tappedStates = Array(repeating: false, count: 5)
            self.originalPortfolioData!.userPurposes.forEach { index in
                if index < self.tappedStates.count {
                    self.tappedStates[index] = true
                }
            }
            self.editView.purposeCollectionView.reloadData()
        }
        view.layoutIfNeeded()
    }
    
    @objc private func editButtonTapped() {
        isEditEnable.toggle()
        editView.toggleEditMode(isEditEnable)
        
        if !isEditEnable {
            let isValidProfile = validateInputs()
            if !isValidProfile.isValid {
                AlertManager.showAlert(on: self,
                                       message: isValidProfile.message ?? "허용되지 않는 값이 입력되었습니다.") {
                    self.isEditEnable = true
                    self.editView.toggleEditMode(self.isEditEnable)
                }
                return
            }
            guard let manager = portfolioManager else { return }
            let body = manager.prepareUpdateRequestBody()

            editMyPort(bodyDTO: body) { success in
                if success {
                    self.editView.portfolioCollectionView.reloadData()
                    self.editView.purposeCollectionView.reloadData()
                    self.view.endEditing(true)
                    self.isDataChanged = false
                    self.editView.editButton.isEnabled = true
                    self.sendAmpliLog(eventName: EventName.CLICK_EDIT_SAVE)
                }
                else {
                    AlertManager.showAlert(on: self,
                                            message: isValidProfile.message ?? "프로필 업데이트 중 오류가 발생했습니다.") {
                        self.isEditEnable = true
                        self.editView.toggleEditMode(self.isEditEnable)
                    }
                }
            }
        } else {
            editView.editButton.isEnabled = false
            self.sendAmpliLog(eventName: EventName.CLICK_EDIT_EDITSTART)
        }
        
        editView.portfolioCollectionView.reloadData()
        editView.purposeCollectionView.reloadData()
    }
    
    @objc private func editProfileLabelTapped() {
        self.sendAmpliLog(eventName: EventName.CLICK_EDIT_PROFILE_EDIT)

        if isEditEnable {
            showUnsavedChangesAlert()
        }
    }
    
    private func showUnsavedChangesAlert() {
        AlertManager.showAlertWithTwoButtons(
            on: self,
            title: "변경사항 저장",
            message: "변경사항을 저장하지 않고 나가시겠습니까?",
            confirmTitle: "예",
            cancelTitle: "아니오",
            confirmAction: { [weak self] in
                guard let self = self else { return }
                self.portfolioManager = nil
                self.setData()
                self.isEditEnable = false
                self.editView.toggleEditMode(false)
                self.sendAmpliLog(eventName: EventName.CLICK_EDIT_PROFILE_EDIT)
            },
            cancelAction: { [weak self] in
                guard let self = self else { return }
                // 현재 상태 유지
                self.isEditEnable = true
                self.editView.toggleEditMode(true)
            }
        )
    }
    
    private func validateInputs() -> ValidationResult {
        return ProfileDataValidator.validateProfile(
            name: editView.nameTextField.text,
            website: editView.websiteTextField.text,
            purposes: portfolioManager?.currentData.userPurposes,
            talents: portfolioManager?.currentData.userTalents,
            nationality: portfolioManager?.currentData.nationality ?? Nationalities.NONE,
            portfolioItemsCount: portfolioManager?.portfolioItems.count ?? 0
        )
    }
}

// MARK: - UICollectionView Delegate & DataSource
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
            
            if let manager = portfolioManager, indexPath.row < manager.portfolioItems.count {
                let item = manager.portfolioItems[indexPath.row]
                cell.isFilled = true
                cell.backgroundImageView.image = item.image
            } else {
                cell.isFilled = false
                cell.backgroundImageView.image = nil
            }
            
            cell.uploadAction = { [weak self] in
                self?.setPortfolio()
                self?.sendAmpliLog(eventName: EventName.CLICK_EDIT_PORTFOLIO)
            }
            
            cell.cancelAction = { [weak self] in
                guard let self = self, let manager = self.portfolioManager, indexPath.row < manager.portfolioItems.count else { return }
                manager.portfolioItems.remove(at: indexPath.row)
                self.sendAmpliLog(eventName: EventName.CLICK_EDIT_PORTFOLIO_DELETE)
                self.isPortfolioFilled = !manager.portfolioItems.isEmpty
                collectionView.reloadData()
                self.checkForChanges()
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
            cell.config(purpose: ProfilePurpose.allCases[indexPath.row])
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

// MARK: - PHPickerViewController Delegate
extension EditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        self.activityIndicator.startAnimating()
        view.addSubview(activityIndicator)

        guard let manager = self.portfolioManager else {
            self.activityIndicator.stopAnimating()
            return
        }

        let currentCount = manager.portfolioItems.count
        let availableSlots = max(0, 10 - currentCount)

        if results.count > availableSlots {
            AlertManager.showAlert(on: self, message: "최대 10장까지만 업로드할 수 있습니다.")
            return
        }

        let group = DispatchGroup()
        var loadedImages = [UIImage]()
        var loadErrors = [Error]()

        for result in results {
            group.enter()
            
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    defer { group.leave() }
                    
                    if let error = error {
                        loadErrors.append(error)
#if DEBUG
                        print("이미지 로딩 실패: \(error.localizedDescription)")
#endif
                        return
                    }

                    guard let image = image as? UIImage else {
#if DEBUG
                        print("로드된 데이터가 UIImage가 아닙니다.")
#endif
                        return
                    }
                    
                    self?.serialQueue.async {
                        loadedImages.append(image)
                    }
                }
            } else {
                group.leave()
#if DEBUG
                print("이 itemProvider는 UIImage를 로딩할 수 없습니다.")
#endif
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            
            if !loadErrors.isEmpty || loadedImages.isEmpty {
                AlertManager.showAlert(on: self, message: "이미지를 불러오는 중 문제가 발생했습니다. iCloud 이미지를 다운로드한 뒤 다시 시도해주세요.")
                self.sendAmpliLog(eventName: EventName.FAIL_IMAGE_LOAD)
                return
            }

            let cropVC = CropImageViewController()
            cropVC.imagesToCrop = loadedImages
            cropVC.delegate     = self
            self.present(cropVC, animated: true)
        }
    }
}

// MARK: - UITextView Delegate
extension EditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextField = textView
        self.sendAmpliLog(eventName: .CLICK_EDIT_DESCRIPTION)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextField = nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty && !textView.text.isOnlyWhitespace() {
            isTextViewFilled = true
        } else {
            isTextViewFilled = false
        }
        if let text = textView.text {
            self.portfolioManager?.currentData.description = text
        }
        scheduleChangeDetection()
    }
}

// MARK: - UITextField Delegate
extension EditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField != editView.websiteTextField, let text = textField.text {
            isTextFieldFilled = !text.isEmpty && !text.isOnlyWhitespace()
        }
        if let text = textField.text {
            switch textField {
            case editView.nameTextField:
                portfolioManager!.currentData.username = text
            case editView.instaTextField:
                portfolioManager!.currentData.instagramId = text
            case editView.websiteTextField:
                portfolioManager!.currentData.webUrl = text
            default:
                break
            }
        }
        checkForChanges()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if textField == editView.instaTextField {
            self.sendAmpliLog(eventName: .CLICK_EDIT_INSTA)
        }
        
        else if textField == editView.websiteTextField {
            self.sendAmpliLog(eventName: .CLICK_EDIT_WEB)
        }
        
        else if textField == editView.nameTextField {
            self.sendAmpliLog(eventName: .CLICK_EDIT_NAME)
        }
        
        if textField == editView.nationalityTextField {
            editView.toggleSaveButtonVisibility(false)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        
        if textField == editView.nationalityTextField {
            editView.toggleSaveButtonVisibility(true)
        }
    }
}

extension EditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedNationality = countries[row]
        editView.nationalityTextField.text = selectedNationality.displayName
        
        if var updatedData = portfolioManager?.currentData {
            updatedData.nationality = selectedNationality
            portfolioManager?.currentData = updatedData
            checkForChanges()
        }
        
        editView.nationalityTextField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == editView.websiteTextField {
            // URL에 필요한 특수문자 허용
            let pattern = "^[a-zA-Z0-9\\s:/?=&._-]*$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            let isMatch = regex?.firstMatch(in: string, options: [], range: range) != nil
            return isMatch
        } else {
            // 영문자, 숫자, 공백만 허용
            let pattern = "^[a-zA-Z0-9\\s]*$"
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            let isMatch = regex?.firstMatch(in: string, options: [], range: range) != nil
            return isMatch
        }
    }
}

extension EditViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, collectionView.tag == 0 {
            let pageWidth = scrollView.frame.width
            let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isInitializing { return }
        
        let currentTime = Date()
        if lastScrollLogTime == nil || currentTime.timeIntervalSince(lastScrollLogTime!) >= scrollLogInterval {
            self.sendAmpliLog(eventName: EventName.SCROLL_EDIT)
            lastScrollLogTime = currentTime
        }
    }
}
