import UIKit
import SafariServices

final class PromotionPopupView: UIView {
    
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let promotionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        // 이미지 설정
        if let image = UIImage(named: "img_promotion_conclave") {
            imageView.image = image
        } else {
            // 이미지가 없을 경우 서버에서 이미지를 다운로드하거나 기본 이미지를 설정할 수 있습니다
            imageView.backgroundColor = .gray
        }
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("24시간 동안 보지 않기", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let promotionURL = "https://www.youtube.com/watch?v=iOt5AZmGg5o"
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        [promotionImageView, closeButton, dismissButton].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            promotionImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            promotionImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            promotionImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            promotionImageView.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -10),
            
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            dismissButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        promotionImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func imageTapped() {
        guard let url = URL(string: promotionURL) else { return }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            let safariViewController = SFSafariViewController(url: url)
            rootViewController.present(safariViewController, animated: true)
        }
    }
    
    @objc private func closeButtonTapped() {
        removeFromSuperview()
    }
    
    @objc private func dismissButtonTapped() {
        // UserDefaults에 24시간 후 날짜 저장
        let twentyFourHoursFromNow = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        UserDefaults.standard.set(twentyFourHoursFromNow, forKey: "PopupDismissDate")
        removeFromSuperview()
    }
} 
