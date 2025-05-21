//
//  FullscreenImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 5/21/25.
//

import Foundation
import UIKit

final class FullscreenImagePagingViewController: UIViewController {
    private var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    var startIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        scrollToStartIndex()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePagingCell.self, forCellWithReuseIdentifier: ImagePagingCell.className)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func scrollToStartIndex() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.startIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
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

        cell.setImage(images[indexPath.item])
        
        cell.onDismissRequested = { [weak self] in
            self?.dismiss(animated: true)
        }

        return cell
    }
}
