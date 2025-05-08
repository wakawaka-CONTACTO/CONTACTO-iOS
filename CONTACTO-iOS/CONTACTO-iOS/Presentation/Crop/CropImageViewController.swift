//
//  CropImageViewController.swift
//  CONTACTO-iOS
//
//  Created by 장아령 on 4/24/25.
//

import UIKit
import SnapKit
import Then

// MARK: - CropImageViewControllerDelegate
protocol CropImageViewControllerDelegate: AnyObject {
    func cropImageViewController(_ controller: CropImageViewController, didCrop image: UIImage)
    func cropImageViewControllerDidCancel(_ controller: CropImageViewController)
}

// MARK: - Constants
private enum Constants {
    static let rotationStep: CGFloat = 90
    static let fullRotation: CGFloat = 360
}

// MARK: - ImageProcessor
private final class ImageProcessor {
    static func crop(image: UIImage, cropFrame: CGRect, contentFrame: CGRect) -> UIImage {
        // 1) Convert cropFrame to image coordinate
        let relativeFrame = CGRect(
            x: cropFrame.minX - contentFrame.minX,
            y: cropFrame.minY - contentFrame.minY,
            width: cropFrame.width,
            height: cropFrame.height
        )
        // 2) Scale factors
        let scaleX = image.size.width / contentFrame.width
        let scaleY = image.size.height / contentFrame.height
        // 3) Pixel-based crop rect
        let pixelRect = CGRect(
            x: relativeFrame.minX * scaleX,
            y: relativeFrame.minY * scaleY,
            width: relativeFrame.width * scaleX,
            height: relativeFrame.height * scaleY
        )
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        let renderSize = CGSize(
            width: pixelRect.width / image.scale,
            height: pixelRect.height / image.scale
        )
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        return renderer.image { _ in
            let origin = CGPoint(
                x: -pixelRect.minX / image.scale,
                y: -pixelRect.minY / image.scale
            )
            image.draw(at: origin)
        }
    }
}

// MARK: - CropImageViewController
final class CropImageViewController: UIViewController {
    // Delegate
    weak var delegate: CropImageViewControllerDelegate?

    // Images
    var imagesToCrop: [UIImage] = []
    private var currentIndex: Int = 0

    private var imageToCrop: UIImage {
        get { imagesToCrop[currentIndex] }
        set { imagesToCrop[currentIndex] = newValue }
    }
    private var isLastImage: Bool { currentIndex == imagesToCrop.count - 1 }

    // Rotation state
    private var currentRotation: CGFloat = 0

    // Subview
    private let cropView = CropImageView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard !imagesToCrop.isEmpty else {
            presentError("No images to crop.")
            return
        }
        setupCropView()
        setupActions()
        loadCurrentImage()
    }

    // MARK: - Setup
    private func setupCropView() {
        view.addSubview(cropView)
        cropView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupActions() {
        cropView.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cropView.cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)
        cropView.rotateLeftButton.addTarget(self, action: #selector(rotateLeftTapped), for: .touchUpInside)
        cropView.rotateRightButton.addTarget(self, action: #selector(rotateRightTapped), for: .touchUpInside)
        cropView.ratioControl.addTarget(self, action: #selector(ratioChanged), for: .valueChanged)
    }

    private func loadCurrentImage() {
        currentRotation = 0
        cropView.imageView.image = imageToCrop
        cropView.ratioControl.selectedSegmentIndex = 0
        cropView.applyRatio(cropView.ratioOptions[0])
        updateCropButtonTitle()
    }

    private func updateCropButtonTitle() {
        let title = isLastImage ? "OK" : "NEXT (\(currentIndex+1)/\(imagesToCrop.count))"
        cropView.cropButton.setTitle(title, for: .normal)
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        view.isHidden = true
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        delegate?.cropImageViewControllerDidCancel(self)
    }

    @objc private func ratioChanged() {
        let ratio = cropView.ratioOptions[cropView.ratioControl.selectedSegmentIndex]
        cropView.applyRatio(ratio)
    }
    	
    @objc private func cropTapped() {
        let selectedRatio = cropView.ratioOptions[cropView.ratioControl.selectedSegmentIndex]
        let result: UIImage

        if selectedRatio == "Fit" {
            result = imageToCrop
        } else {
            // ① 테두리 두께 가져오기
            let bw = cropView.cropAreaView.layer.borderWidth

            // ② 원래 프레임에서 테두리만큼 안쪽으로 들여쓰기
            let rawFrame = cropView.cropAreaView.frame
            let insetFrame = rawFrame.insetBy(dx: bw, dy: bw)

            // ③ 보정된 프레임으로 크롭
            result = ImageProcessor.crop(
                image: imageToCrop,
                cropFrame: insetFrame,
                contentFrame: cropView.imageDisplayFrame()
            )
        }

        delegate?.cropImageViewController(self, didCrop: result)

        if !isLastImage {
            currentIndex += 1
            loadCurrentImage()
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func rotateLeftTapped() {
        rotate(by: -Constants.rotationStep)
    }
    @objc private func rotateRightTapped() {
        rotate(by: Constants.rotationStep)
    }

    private func rotate(by degrees: CGFloat) {
        currentRotation = fmod(currentRotation + degrees + Constants.fullRotation, Constants.fullRotation)
        let rotated = imageToCrop.rotated(by: degrees)
        imageToCrop = rotated
        cropView.imageView.image = rotated
        ratioChanged()
    }
}

// MARK: - UIImage Extension
private extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        let newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        ctx.translateBy(x: newSize.width/2, y: newSize.height/2)
        ctx.rotate(by: radians)
        draw(in: CGRect(x: -size.width/2, y: -size.height/2,
                        width: size.width, height: size.height))
        let rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotated ?? self
    }
}
