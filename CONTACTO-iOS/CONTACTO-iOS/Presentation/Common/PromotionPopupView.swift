import UIKit
import SafariServices

struct PromotionItem {
    let imageName: String
    let url: String
}

final class PromotionPopupView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PromotionImageCellDelegate {
    
    // MARK: - Properties
    private let items: [PromotionItem]
    private var currentIndex: Int = 0 {
        didSet {
            updateArrowButtons()
        }
    }
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PromotionImageCell.self, forCellWithReuseIdentifier: "PromotionImageCell")
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("12시간 동안 보지 않기", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let leftArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.isHidden = false
        return button
    }()
    
    private let rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.isHidden = false
        return button
    }()
    
    // MARK: - Lifecycle
    init?(frame: CGRect, items: [PromotionItem]) {
        guard !items.isEmpty else { return nil }
        self.items = items
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        [collectionView, dismissButton, leftArrowButton, rightArrowButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -10),
            
            dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            dismissButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            leftArrowButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            leftArrowButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            leftArrowButton.widthAnchor.constraint(equalToConstant: 28),
            leftArrowButton.heightAnchor.constraint(equalToConstant: 28),
            
            rightArrowButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            rightArrowButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            rightArrowButton.widthAnchor.constraint(equalToConstant: 28),
            rightArrowButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        leftArrowButton.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        rightArrowButton.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        updateArrowButtons()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionImageCell", for: indexPath) as? PromotionImageCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        cell.configure(with: item.imageName)
        cell.delegate = self
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        guard let url = URL(string: item.url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        if let topVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            var presentedVC = topVC
            while let next = presentedVC.presentedViewController {
                presentedVC = next
            }
            presentedVC.present(safariViewController, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        currentIndex = page
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 340)
    }
    
    // MARK: - PromotionImageCellDelegate
    func promotionImageCellDidTap(_ cell: PromotionImageCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let item = items[indexPath.item]
            guard let url = URL(string: item.url) else { return }
            let safariViewController = SFSafariViewController(url: url)
            if let topVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                var presentedVC = topVC
                while let next = presentedVC.presentedViewController {
                    presentedVC = next
                }
                presentedVC.present(safariViewController, animated: true)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func dismissButtonTapped() {
        let twelveHoursFromNow = Calendar.current.date(byAdding: .hour, value: 12, to: Date())
        UserDefaults.standard.set(twelveHoursFromNow, forKey: "PopupDismissDate")
        removeFromSuperview()
    }
    
    @objc private func leftArrowTapped() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc private func rightArrowTapped() {
        guard currentIndex < items.count - 1 else { return }
        currentIndex += 1
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func updateArrowButtons() {
        leftArrowButton.isEnabled = currentIndex > 0
        leftArrowButton.alpha = currentIndex > 0 ? 1.0 : 0.3
        rightArrowButton.isEnabled = currentIndex < items.count - 1
        rightArrowButton.alpha = currentIndex < items.count - 1 ? 1.0 : 0.3
    }
}

protocol PromotionImageCellDelegate: AnyObject {
    func promotionImageCellDidTap(_ cell: PromotionImageCell)
}

class PromotionImageCell: UICollectionViewCell {
    private let imageView = UIImageView()
    weak var delegate: PromotionImageCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        contentView.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with imageName: String) {
        if let image = UIImage(named: imageName) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .gray
            imageView.image = nil
        }
    }
    @objc private func imageTapped() {
        delegate?.promotionImageCellDidTap(self)
    }
} 
