//
//  EditView.swift
//  CONTACTO-iOS
//
//  Created by 정채은 on 10/7/24.
//

import UIKit

import SnapKit
import Then

final class EditView: BaseView, EditAmplitudeSender {
        
    private let topView = UIView()
    private let topImageView = UIImageView()
    
    let scrollView = UIScrollView()
    private let contentsView = UIView()
    let editLabel = UILabel()
    private let editLineView = UIView()
    let previewButton = UIButton()
    
    let nameTextField = UITextField()
    
    private let nationalityLabel = UILabel()
    let nationalityTextField = UITextField()
    let nationalityPicker = UIPickerView()
    
    lazy var portfolioCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: portfolioFlowLayout
    )
    private let portfolioFlowLayout = UICollectionViewFlowLayout()
    
    let talentLabel = UILabel()
    let talentEditButton = UIButton()
    lazy var talentCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: talentFlowLayout
    )
    private let talentFlowLayout = LeftAlignedCollectionViewFlowLayout()
    
    private let descriptionLabel = UILabel()
    let descriptionTextView = UITextView()
    
    private let purposeLabel = UILabel()
    lazy var purposeCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: purposeFlowLayout
    )
    private let purposeFlowLayout = UICollectionViewFlowLayout()
    
    private let snsWebLabel = UILabel()
    private let instaLabel = UILabel()
    private let instaAtLabel = UILabel()
    let instaTextField = UITextField()
    private let websiteLabel = UILabel()
    let websiteTextField = UITextField()
    
    let cancelButton = UIButton()
    let editButton = UIButton()
    
    override func setStyle() {
        self.backgroundColor = .ctgray4
        
        topView.do {
            $0.backgroundColor = .ctsuborange
        }
        
        topImageView.do {
            $0.image = .imgEditTopLogo
            $0.contentMode = .scaleAspectFit
        }
        
        editLabel.do {
            $0.text = StringLiterals.Edit.profileEdit
            $0.font = .fontContacto(.button4)
            $0.textColor = .ctblack
        }
        
        editLineView.do {
            $0.backgroundColor = .ctblack
        }
        
        previewButton.do {
            $0.setTitle(StringLiterals.Edit.preview, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button4)
        }
        
        nameTextField.do {
            $0.backgroundColor = .ctmainblue
            $0.text = " "
            $0.font = .fontContacto(.button4)
            $0.textColor = .ctblack
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.keyboardType = .asciiCapable
            $0.isEnabled = false
            $0.textAlignment = .center
        }
        
        nationalityLabel.do {
            $0.text = "\(StringLiterals.Onboarding.Nationality.title)  \(StringLiterals.Onboarding.SNS.required)"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
            $0.asFont(targetString: "  \(StringLiterals.Onboarding.SNS.required)", font: .fontContacto(.caption3))
        }
        
        nationalityTextField.do {
            $0.backgroundColor = .clear
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.isEnabled = false
            $0.textAlignment = .left
            $0.addPadding(left: 10)
            $0.inputView = nationalityPicker
        }
        
        portfolioCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.tag = 0
        }
        
        portfolioFlowLayout.do {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 10
            $0.itemSize = CGSize(width: 198, height: 260)
        }
        
        talentLabel.do {
            $0.text = StringLiterals.Edit.talent
            $0.font = .fontContacto(.body3)
            $0.textColor = .ctblack
        }
        
        talentCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 1
        }
        
        talentFlowLayout.do {
            $0.minimumLineSpacing = 5.adjustedWidth
            $0.minimumInteritemSpacing = 4
            $0.estimatedItemSize = CGSize(width: .bitWidth, height: 19)
        }
        
        talentEditButton.do {
            $0.setImage(.icEdit, for: .normal)
            $0.isHidden = true
        }
        
        descriptionLabel.do {
            $0.text = StringLiterals.Edit.originality
            $0.font = .fontContacto(.body3)
            $0.textColor = .ctblack
        }
        
        descriptionTextView.do {
            $0.backgroundColor = .clear
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.text = " "
            $0.textAlignment = .left
            $0.font = .fontContacto(.caption5)
            $0.textColor = .ctblack
            $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.isEditable = false
        }
        
        purposeLabel.do {
            $0.text = StringLiterals.Edit.purpose
            $0.font = .fontContacto(.body3)
            $0.textColor = .ctblack
        }
        
        purposeCollectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.tag = 2
        }
        
        purposeFlowLayout.do {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 12.adjustedWidth
            $0.minimumInteritemSpacing = 13.adjustedHeight
            $0.itemSize = CGSize(width: (SizeLiterals.Screen.screenWidth - 44.adjustedWidth) / 2, height: 28.adjustedHeight)
        }
        
        snsWebLabel.do {
            $0.text = StringLiterals.Edit.sns
            $0.font = .fontContacto(.body3)
            $0.textColor = .ctblack
        }
        
        instaLabel.do {
            $0.text = "\(StringLiterals.Onboarding.SNS.instagram)  \(StringLiterals.Onboarding.SNS.required)"
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
            $0.asFont(targetString: "  \(StringLiterals.Onboarding.SNS.required)", font: .fontContacto(.caption3))
        }
        
        instaTextField.do {
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .clear
            $0.textColor = .ctblack
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.addPadding(left: 27)
            $0.autocapitalizationType = .none
            $0.keyboardType = .asciiCapable
            $0.text = " "
            $0.isEnabled = false
        }
        
        instaAtLabel.do {
            $0.text = "@"
            $0.font = .fontContacto(.button1)
            $0.textColor = .ctblack
        }
        
        websiteLabel.do {
            $0.text = StringLiterals.Onboarding.SNS.website
            $0.textColor = .ctblack
            $0.font = .fontContacto(.body1)
        }
        
        websiteTextField.do {
            $0.changePlaceholderColor(forPlaceHolder: StringLiterals.Onboarding.SNS.example, forColor: .ctgray2)
            $0.font = .fontContacto(.button1)
            $0.textAlignment = .left
            $0.borderStyle = .line
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.backgroundColor = .clear
            $0.textColor = .ctblack
            $0.returnKeyType = .done
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.autocapitalizationType = .none
            $0.addPadding(left: 10)
            $0.isEnabled = false
        }
        
        cancelButton.do {
            $0.setImage(.icUndo, for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctwhite, for: .normal)
            $0.isHidden = true
        }
        
        editButton.do {
            $0.setTitle(StringLiterals.Edit.editButton, for: .normal)
            $0.setTitleColor(.ctblack, for: .normal)
            $0.titleLabel?.font = .fontContacto(.button2)
            $0.setRoundBorder(borderColor: .ctblack, borderWidth: 1.5, cornerRadius: 0)
            $0.setBackgroundColor(.ctsubyellow1, for: .normal)
            $0.setBackgroundColor(.ctgray3, for: .disabled)
            
        }
    }
    
    override func setLayout() {
        addSubviews(topView,
                    scrollView,
                    cancelButton,
                    editButton)
        topView.addSubviews(topImageView)
        scrollView.addSubviews(contentsView)
        contentsView.addSubviews(editLabel,
                                 editLineView,
                                 previewButton,
                                 nameTextField,
                                 nationalityLabel,
                                 nationalityTextField,
                                 portfolioCollectionView,
                                 talentLabel,
                                 talentEditButton,
                                 talentCollectionView,
                                 descriptionLabel,
                                 descriptionTextView,
                                 purposeLabel,
                                 purposeCollectionView,
                                 snsWebLabel,
                                 instaLabel,
                                 instaTextField,
                                 websiteLabel,
                                 websiteTextField)
        instaTextField.addSubviews(instaAtLabel)
        
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(98.adjustedHeight)
        }
        
        topImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contentsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(SizeLiterals.Screen.screenWidth)
        }
        
        editLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview().offset(-SizeLiterals.Screen.screenWidth/4.5)
        }
        
        editLineView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(editLabel)
            $0.centerX.equalTo(editLabel)
            $0.top.equalTo(editLabel.snp.bottom)
        }
        
        previewButton.snp.makeConstraints {
            $0.centerY.equalTo(editLabel)
            $0.centerX.equalToSuperview().offset(SizeLiterals.Screen.screenWidth/4.5)
        }
        
        nameTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(previewButton.snp.bottom).offset(21)
            $0.height.equalTo(32)
        }
        
        nationalityLabel.snp.makeConstraints {
            $0.top.equalTo(websiteTextField.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        nationalityTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(nameTextField)
            $0.top.equalTo(nationalityLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        portfolioCollectionView.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(13)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(260)
        }
        
        talentLabel.snp.makeConstraints {
            $0.top.equalTo(portfolioCollectionView.snp.bottom).offset(34)
            $0.leading.equalToSuperview().inset(16)
        }
        
        talentEditButton.snp.makeConstraints {
            $0.centerY.equalTo(talentLabel)
            $0.leading.equalTo(talentLabel.snp.trailing).offset(-1.5)
        }
        
        talentCollectionView.snp.makeConstraints {
            $0.top.equalTo(talentLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(talentCollectionView.contentSize.height)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(talentCollectionView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().inset(16)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(89)
        }
        
        purposeLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(27)
            $0.leading.equalToSuperview().inset(16)
        }
        
        purposeCollectionView.snp.makeConstraints {
            $0.top.equalTo(purposeLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(110.adjustedHeight)
        }
        
        snsWebLabel.snp.makeConstraints {
            $0.top.equalTo(purposeCollectionView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().inset(16)
        }
        
        instaLabel.snp.makeConstraints {
            $0.top.equalTo(snsWebLabel.snp.bottom).offset(14.adjustedHeight)
            $0.leading.equalToSuperview().inset(16)
        }
        
        instaTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(instaLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        instaAtLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
        
        websiteLabel.snp.makeConstraints {
            $0.top.equalTo(instaTextField.snp.bottom).offset(11)
            $0.leading.equalTo(instaLabel)
        }
        
        websiteTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(instaTextField)
            $0.top.equalTo(websiteLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
        }
        
        nationalityLabel.snp.makeConstraints {
            $0.top.equalTo(websiteTextField.snp.bottom).offset(11)
            $0.leading.equalTo(websiteLabel)
        }
        
        nationalityTextField.snp.makeConstraints {
            $0.leading.trailing.height.equalTo(websiteTextField)
            $0.top.equalTo(nationalityLabel.snp.bottom).offset(10.adjustedHeight)
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(100)
        }

        editButton.snp.makeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
        
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.width.equalTo(cancelButton.snp.height)
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
        }
    }
    
    var editAction: (() -> Void) = {}
    
    func toggleEditMode(_ isEditEnabled: Bool) {
        nameTextField.isEnabled = isEditEnabled
        nameTextField.backgroundColor = isEditEnabled ? .ctwhite : .ctmainblue
        talentEditButton.isHidden = !isEditEnabled
        descriptionTextView.isEditable = isEditEnabled
        descriptionTextView.backgroundColor = isEditEnabled ? .ctwhite : .clear
        instaTextField.isEnabled = isEditEnabled
        websiteTextField.isEnabled = isEditEnabled
        instaTextField.backgroundColor = isEditEnabled ? .ctwhite : .clear
        websiteTextField.backgroundColor = isEditEnabled ? .ctwhite : .clear
        nationalityTextField.isEnabled = isEditEnabled
        nationalityTextField.backgroundColor = isEditEnabled ? .ctwhite : .clear

        editButton.setTitle(isEditEnabled ? StringLiterals.Edit.saveButton : StringLiterals.Edit.editButton, for: .normal)
        editButton.setBackgroundColor(isEditEnabled ? .ctsubgreen3 : .ctsubyellow1, for: .normal)
        editButton.isEnabled = isEditEnabled
        cancelButton.isHidden = !isEditEnabled

        editButton.snp.remakeConstraints {
            $0.height.equalTo(34.adjustedHeight)
            $0.bottom.equalToSuperview().inset(41.adjustedHeight)
            editAction()

            if isEditEnabled {
                $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(16)
            } else {
                $0.leading.trailing.equalToSuperview().inset(16)
            }
        }
    }
    
    public func toggleSaveButtonVisibility(_ isVisible: Bool) {
        editButton.isHidden = !isVisible
    }
}
