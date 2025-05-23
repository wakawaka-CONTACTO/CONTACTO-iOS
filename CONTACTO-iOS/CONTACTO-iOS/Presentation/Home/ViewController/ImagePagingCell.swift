import UIKit
import SnapKit

final class ImagePagingCell: UICollectionViewCell {
    // MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let skeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray.withAlphaComponent(0.3)
        view.isHidden = true
        return view
    }()
    
    var onDismissRequested: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        contentView.addSubview(skeletonView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
        
        skeletonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.delegate = self
    }
    
    private func setupGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapGesture.require(toFail: doubleTapGesture)
        contentView.addGestureRecognizer(singleTapGesture)
    }
    
    // MARK: - Public Methods
    func setImage(_ image: UIImage) {
        imageView.image = image
        resetZoom()
    }
    
    func showSkeleton() {
        skeletonView.isHidden = false
        imageView.isHidden = true
        startSkeletonAnimation()
    }
    
    func hideSkeleton() {
        skeletonView.isHidden = true
        imageView.isHidden = false
        stopSkeletonAnimation()
    }
    
    // MARK: - Private Methods
    private func resetZoom() {
        scrollView.setZoomScale(1.0, animated: false)
        scrollView.contentOffset = .zero
    }
    
    private func startSkeletonAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.3
        animation.toValue = 0.7
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.autoreverses = true
        skeletonView.layer.add(animation, forKey: "skeletonAnimation")
    }
    
    private func stopSkeletonAnimation() {
        skeletonView.layer.removeAnimation(forKey: "skeletonAnimation")
    }
    
    // MARK: - Actions
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            resetZoom()
        } else {
            let point = gesture.location(in: imageView)
            let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
            scrollView.zoom(to: rect, animated: true)
        }
    }
    
    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        onDismissRequested?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        hideSkeleton()
    }
}

// MARK: - UIScrollViewDelegate
extension ImagePagingCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
} 