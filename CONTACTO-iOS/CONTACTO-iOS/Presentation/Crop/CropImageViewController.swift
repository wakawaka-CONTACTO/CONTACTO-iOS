//
//  CropImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//

import Foundation
import SnapKit
import Then
import PhotosUI

// MARK: - CropImageViewControllerDelegate
protocol CropImageViewControllerDelegate: AnyObject {
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage)
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController)
}

// MARK: - CropImageViewController
/// Controller that manages user interactions for cropping an image
final class CropImageViewController: UIViewController {
    weak var delegate: CropImageViewControllerDelegate?
    var imageToCrop: UIImage!

    private let cropView = CropImageView()
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cropView)
        cropView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        cropView.imageView.image = imageToCrop
        cropView.ratioControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
        cropView.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cropView.cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)

        setupGestures()
        cropView.applyRatio(cropView.ratioOptions.first!)
    }

    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cropView.cropAreaView.addGestureRecognizer(panGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        cropView.cropAreaView.addGestureRecognizer(pinchGesture)
    }

    @objc private func ratioChanged() {
        let ratio = cropView.ratioOptions[cropView.ratioControl.selectedSegmentIndex]
        cropView.applyRatio(ratio)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cropView.imageView)
        cropView.cropAreaView.center = CGPoint(x: cropView.cropAreaView.center.x + translation.x,
                                              y: cropView.cropAreaView.center.y + translation.y)
        gesture.setTranslation(.zero, in: cropView.imageView)
        cropView.updateOverlayMask()
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        cropView.cropAreaView.transform = cropView.cropAreaView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
        cropView.updateOverlayMask()
    }

    @objc private func cancelTapped() {
        delegate?.cropImageViewControllerDidCancel(self)
    }

    @objc private func cropTapped() {
        guard let image = imageToCrop, let cgImage = image.cgImage else { return }
        let frame = cropView.imageView.convert(cropView.cropAreaView.frame, from: cropView)
        let scale = max(cropView.imageView.frame.width / image.size.width,
                        cropView.imageView.frame.height / image.size.height)
        let rect = CGRect(x: (frame.origin.x - cropView.imageView.frame.minX)/scale,
                          y: (frame.origin.y - cropView.imageView.frame.minY)/scale,
                          width: frame.size.width/scale,
                          height: frame.size.height/scale)
        if let croppedCG = cgImage.cropping(to: rect) {
            let cropped = UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
            delegate?.cropImageViewController(self, didCrop: cropped)
        }
    }
}
