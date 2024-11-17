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
    
    private var portfolioData = MyDetailResponseDTO(id: 0, username: "", socialId: nil, loginType: "", email: "", description: "", instagramId: "", webUrl: nil, password: nil, userPortfolio: UserPortfolio(portfolioId: 0, userId: 0, portfolioImages: []), userPurposes: [], userTalents: [])
    private var talentData: [TalentInfo] = []
    var isEditEnable = false
    var tappedStates: [Bool] = Array(repeating: false, count: 5)
    private var activeTextField: UIView?
    
    var isTextFieldFilled = true {
        didSet {
            changeSaveButtonStatus()
        }
    }
    var isTextViewFilled = true { // 확인 필요. data 들어갔을 때도
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
        setClosure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        self.addKeyboardNotifications()
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
    }
    
    private func setClosure() {
        editView.editAction = {
            self.isEditEnable.toggle()
            self.editView.portfolioCollectionView.reloadData()
            self.editView.purposeCollectionView.reloadData()
            self.view.endEditing(true)
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
    private func myList(bodyDTO: EditRequestBodyDTO, completion: @escaping (Bool) -> Void) {
        NetworkService.shared.editService.editMyPort(bodyDTO: bodyDTO) { [weak self] response in
            switch response {
            case .success(let data):
                guard let data = data.data else { return }
                print(data)
                completion(true)
            default:
                completion(false)
                print("error")
            }
        }
    }
    
    private func checkMyPort(completion: @escaping (Bool) -> Void) {
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
        }
    }
    
    private func updatePortfolio() {
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
        
        portfolioData.userPortfolio.portfolioImages.forEach { url in
            guard let imageUrl = URL(string: url) else { return }
            
            dispatchGroup.enter() // 작업 시작
            KingfisherManager.shared.downloader.downloadImage(with: imageUrl) { [weak self] result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self?.selectedImages.append(value.image)
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
                tappedStates[index - 1] = true
            }
        }
        
        editView.talentCollectionView.reloadData()
        editView.purposeCollectionView.reloadData()
    }
    
    private func setData() {
        self.checkMyPort { _ in
            self.editView.talentCollectionView.layoutIfNeeded()
            
            self.editView.talentCollectionView.snp.remakeConstraints {
                $0.top.equalTo(self.editView.talentLabel.snp.bottom).offset(7)
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.height.equalTo(self.editView.talentCollectionView.contentSize.height + 4)
            }
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
    
    private func changeSaveButtonStatus() {
        if isTextFieldFilled,
           isTextViewFilled,
           isPortfolioFilled,
           isPurposeFilled,
           isEditEnable {
            editView.editButton.isEnabled = true
        } else {
            editView.editButton.isEnabled = false
        }
    }
    
    private func tapAroundKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
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
        
        self.editView.editButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight - tabBarHeight + 13.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        // 현재 활성화된 텍스트 필드가 있는지 확인
        if let activeField = activeTextField {
            print(activeField)
            if activeField.frame.minY > (view.frame.height - keyboardHeight) {
                let yOffset = activeField.frame.maxY - (view.frame.height + tabBarHeight - keyboardHeight) + 45.adjustedHeight
                editView.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardHeight + yOffset), animated: false)
            }
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification){
        self.editView.editButton.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
        
        if let activeField = activeTextField {
            if activeField == editView.instaTextField || activeField == editView.websiteTextField {
                editView.scrollView.setContentOffset(CGPoint(x: 0,
                                                             y: editView.scrollView.contentSize.height - editView.scrollView.bounds.height),
                                                     animated: true)
            }
        }
        
        UIView.animate(withDuration: 2, delay: 0, options:.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension EditViewController {
    @objc private func previewButtonTapped() {
        let previewViewController = HomeViewController()
        previewViewController.isPreview = true
        previewViewController.portfolioData = self.portfolioData
        previewViewController.imageDummy = selectedImages
        let navigationController = UINavigationController(rootViewController: previewViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func talentEditButtonTapped() {
        let talentViewController = TalentOnboardingViewController()
        talentViewController.hidesBottomBarWhenPushed = true
        talentViewController.talentOnboardingView.nextButton.setTitle(StringLiterals.Edit.doneButton, for: .normal)
        talentViewController.talentOnboardingView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        talentViewController.isEdit = true
        talentViewController.editTalent = talentData
        navigationController?.pushViewController(talentViewController, animated: true)
    }
    
    @objc private func nextButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension EditViewController: UICollectionViewDelegate { }

extension EditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 10
        case 1:
            return portfolioData.userTalents.count
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
            self.editView.portfolioCollectionView.reloadData()
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
        if !textView.text.isEmpty, !textView.text.isOnlyWhitespace() {
            self.isTextViewFilled = true
        } else {
            self.isTextViewFilled = false
        }
    }
}

extension EditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField != editView.websiteTextField  {
            if !textField.text!.isEmpty,  !textField.text!.isOnlyWhitespace() {
                self.isTextFieldFilled = true
            } else {
                self.isTextFieldFilled = false
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
