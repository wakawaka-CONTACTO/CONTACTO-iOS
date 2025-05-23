//
//  FullscreenImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 5/21/25.
//

import Foundation
import UIKit
import SnapKit

final class FullscreenImagePagingViewController: UIViewController {
    // MARK: - Properties
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePagingCell.self, forCellWithReuseIdentifier: ImagePagingCell.className)
        return collectionView
    }()
    
    private var pageLabel: UILabel!
    private var closeButton: UIButton!
    
    var images: [UIImage] = []
    var startIndex: Int = 0
    var isLoading: Bool = false {
        didSet {
            reloadImages()
        }
    }
    
    // MARK: - Public Methods
    func reloadImages() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        scrollToStartIndex()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        setupCloseButton()
        setupPageLabel()
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(44)
        }
    }
    
    private func setupPageLabel() {
        pageLabel = UILabel()
        pageLabel.textColor = .white
        pageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        pageLabel.textAlignment = .center
        updatePageLabel()
        
        view.addSubview(pageLabel)
        pageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func scrollToStartIndex() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.startIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.updatePageLabel()
        }
    }
    
    private func updatePageLabel() {
        let width = collectionView.frame.width
        guard width > 0, !images.isEmpty else {
             pageLabel.text = "0/0"
            return
        }
        let currentPage = max(1, min(images.count, Int(round(collectionView.contentOffset.x / width)) + 1))
        let totalPages = max(1, images.count)
        pageLabel.text = "\(currentPage)/\(totalPages)"
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension FullscreenImagePagingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImagePagingCell.className,
            for: indexPath
        ) as? ImagePagingCell else {
            return UICollectionViewCell()
        }

        if isLoading {
            cell.showSkeleton()
        } else {
            cell.hideSkeleton()
            if indexPath.item < images.count {
                cell.setImage(images[indexPath.item])
            }
        }
        
        cell.onDismissRequested = { [weak self] in
            self?.dismiss(animated: true)
        }

        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageLabel()
    }
}
