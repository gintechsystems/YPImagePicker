//
//  YPLibraryView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos
import PhotosUI

internal final class YPLibraryView: UIView {

    // MARK: - Public vars

    internal let assetZoomableViewMinimalVisibleHeight: CGFloat  = 50
    internal var assetViewContainerConstraintTop: NSLayoutConstraint?
    internal let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
        v.collectionViewLayout = layout
        v.showsHorizontalScrollIndicator = false
        v.alwaysBounceVertical = true
        return v
    }()
    internal lazy var assetViewContainer: YPAssetViewContainer = {
        let v = YPAssetViewContainer(frame: .zero, zoomableView: assetZoomableView)
        v.accessibilityIdentifier = "assetViewContainer"
        return v
    }()
    internal let assetZoomableView: YPAssetZoomableView = {
        let v = YPAssetZoomableView(frame: .zero)
        v.accessibilityIdentifier = "assetZoomableView"
        return v
    }()
    /// At the bottom there is a view that is visible when selected a limit of items with multiple selection
    internal let maxNumberWarningView: UIView = {
        let v = UIView()
        v.backgroundColor = .ypSecondarySystemBackground
        v.isHidden = true
        return v
    }()
    internal let maxNumberWarningLabel: UILabel = {
        let v = UILabel()
        v.font = YPConfig.fonts.libaryWarningFont
        return v
    }()
    
    /// Select more bar that appears when photo library authorization is limited
    internal let selectMoreBar: UIView = {
        let v = UIView()
        v.backgroundColor = YPConfig.colors.libraryScreenBackgroundColor
        v.isHidden = true
        return v
    }()
    
    internal let selectMoreStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .fill
        v.spacing = 8
        return v
    }()
    
    internal let selectMoreIcon: UIImageView = {
        let v = UIImageView()
        if #available(iOS 13.0, *) {
            v.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
        v.tintColor = YPConfig.colors.tintColor
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    internal let selectMoreLabel: UILabel = {
        let v = UILabel()
        v.text = "Select more..."
        v.font = YPConfig.fonts.libaryWarningFont
        v.textColor = YPConfig.colors.tintColor
        return v
    }()

    // MARK: - Private vars

    private let line: UIView = {
        let v = UIView()
        v.backgroundColor = .ypSystemBackground
        return v
    }()
    /// When video is processing this bar appears
    private let progressView: UIProgressView = {
        let v = UIProgressView()
        v.progressViewStyle = .bar
        v.trackTintColor = YPConfig.colors.progressBarTrackColor
        v.progressTintColor = YPConfig.colors.progressBarCompletedColor ?? YPConfig.colors.tintColor
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    private let collectionContainerView: UIView = {
        let v = UIView()
        v.accessibilityIdentifier = "collectionContainerView"
        return v
    }()
    private var shouldShowLoader = false {
        didSet {
            DispatchQueue.main.async {
                self.assetViewContainer.squareCropButton.isEnabled = !self.shouldShowLoader
                self.assetViewContainer.multipleSelectionButton.isEnabled = !self.shouldShowLoader
                self.assetViewContainer.spinnerIsShown = self.shouldShowLoader
                self.shouldShowLoader ? self.hideOverlayView() : ()
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSelectMoreBar()
        setupLayout()
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Only code layout.")
    }

    // MARK: - Public Methods

    // MARK: Overlay view

    func hideOverlayView() {
        assetViewContainer.itemOverlay?.alpha = 0
    }

    // MARK: Loader and progress

    func fadeInLoader() {
        shouldShowLoader = true
        // Only show loader if full res image takes more than 0.5s to load.
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            if self.shouldShowLoader == true {
                UIView.animate(withDuration: 0.2) {
                    self.assetViewContainer.spinnerView.alpha = 1
                }
            }
        }
    }

    func hideLoader() {
        shouldShowLoader = false
        assetViewContainer.spinnerView.alpha = 0
    }

    func updateProgress(_ progress: Float) {
        progressView.isHidden = progress > 0.99 || progress == 0
        progressView.progress = progress
        UIView.animate(withDuration: 0.1, animations: progressView.layoutIfNeeded)
    }

    // MARK: Crop Rect

    func currentCropRect() -> CGRect {
        let cropView = assetZoomableView
        let normalizedX = min(1, cropView.contentOffset.x &/ cropView.contentSize.width)
        let normalizedY = min(1, cropView.contentOffset.y &/ cropView.contentSize.height)
        let normalizedWidth = min(1, cropView.frame.width / cropView.contentSize.width)
        let normalizedHeight = min(1, cropView.frame.height / cropView.contentSize.height)
        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }

    // MARK: Curtain

    func refreshImageCurtainAlpha() {
        let imageCurtainAlpha = abs(assetViewContainerConstraintTop?.constant ?? 0)
        / (assetViewContainer.frame.height - assetZoomableViewMinimalVisibleHeight)
        assetViewContainer.curtain.alpha = imageCurtainAlpha
    }

    func cellSize() -> CGSize {
        var screenWidth = window?.windowScene?.screen.bounds.width ?? 1.0
        let scale = window?.windowScene?.screen.scale ?? 1.0
        if UIDevice.current.userInterfaceIdiom == .pad && YPImagePickerConfiguration.widthOniPad > 0 {
            screenWidth =  YPImagePickerConfiguration.widthOniPad
        }
        let size = screenWidth / 4 * scale
        return CGSize(width: size, height: size)
    }
    
    // MARK: - Select More Bar
    
    func updateSelectMoreBarVisibility() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        let shouldShow = status == .limited
        
        UIView.animate(withDuration: 0.3) {
            self.selectMoreBar.isHidden = !shouldShow
            self.selectMoreBar.heightConstraint?.constant = (!shouldShow ? 0.0 : 40.0)
            self.layoutIfNeeded()
        }
    }

    // MARK: - Private Methods
    
    private func setupSelectMoreBar() {
        selectMoreStackView.addArrangedSubview(selectMoreIcon)
        selectMoreStackView.addArrangedSubview(selectMoreLabel)
        
        // Add tap gesture to the select more bar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectMoreBarTapped))
        selectMoreBar.addGestureRecognizer(tapGesture)
        selectMoreBar.isUserInteractionEnabled = true
    }
    
    @objc private func selectMoreBarTapped() {
        if let viewController = self.findViewController() {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
        }
    }

    private func setupLayout() {
        subviews(
            collectionContainerView.subviews(
                collectionView
            ),
            line,
            selectMoreBar.subviews(
                selectMoreStackView
            ),
            assetViewContainer.subviews(
                assetZoomableView
            ),
            progressView,
            maxNumberWarningView.subviews(
                maxNumberWarningLabel
            )
        )

        collectionContainerView.fillContainer()
        collectionView.fillHorizontally().bottom(0)

        assetViewContainer.Bottom == line.Top
        line.height(1)
        line.fillHorizontally()

        selectMoreBar.fillHorizontally().height(0)
        selectMoreBar.Top == line.Bottom
        selectMoreStackView.centerInContainer()
        selectMoreIcon.width(20).height(20)

        assetViewContainer.top(0).fillHorizontally().heightEqualsWidth()
        self.assetViewContainerConstraintTop = assetViewContainer.topConstraint
        assetZoomableView.fillContainer().heightEqualsWidth()
        collectionView.Top == selectMoreBar.Bottom
        assetViewContainer.sendSubviewToBack(assetZoomableView)

        progressView.height(5).fillHorizontally()
        progressView.Bottom == line.Top

        |maxNumberWarningView|.bottom(0)
        maxNumberWarningView.Top == safeAreaLayoutGuide.Bottom - 40
        maxNumberWarningLabel.centerHorizontally().top(11)
    }
}

// MARK: - UIView Extension
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
