//
//  ImagePagingCell.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 5/21/25.
//

import UIKit


final class ImagePagingCell: UICollectionViewCell {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var onDismissRequested: (() -> Void)?

    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        imageView.addGestureRecognizer(tap)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    @objc private func dismissTapped() {
        onDismissRequested?()
    }
}
