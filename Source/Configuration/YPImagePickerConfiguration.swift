//
//  YPImagePickerConfiguration.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 18/10/2017.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

/// Typealias for code prettiness
internal var YPConfig: YPImagePickerConfiguration { return YPImagePickerConfiguration.shared }

public struct YPImagePickerConfiguration {
    public static var shared: YPImagePickerConfiguration = YPImagePickerConfiguration()
    
    public static var widthOniPad: CGFloat = -1
    
    public static var screenWidth: CGFloat {
        var screenWidth: CGFloat = 0
        
        if Thread.isMainThread {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            screenWidth = windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        } else {
            // Fallback to UIScreen.main when not on main thread
            screenWidth = UIScreen.main.bounds.width
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad && YPImagePickerConfiguration.widthOniPad > 0 {
            screenWidth = YPImagePickerConfiguration.widthOniPad
        }
        return screenWidth
    }

    /// If don't want to have logs from picker, set it to false.
    public var isDebugLogsEnabled: Bool = true

    public init() {}
    
    /// Library configuration
    public var library = YPConfigLibrary()
    
    /// Video configuration
    public var video = YPConfigVideo()
    
    /// Gallery configuration
    public var gallery = YPConfigSelectionsGallery()
    
    /// Use this property to modify the default wordings provided.
    public var wordings = YPWordings()
    
    /// Use this property to modify the default icons provided.
    public var icons = YPIcons()
    
    /// Use this property to modify the default colors provided.
    public var colors = YPColors()

    /// Use this property to modify the default fonts provided
    public var fonts = YPFonts()

    /// Scroll to change modes, defaults to true
    public var isScrollToChangeModesEnabled = true

    /// Set this to true if you want to force the camera output to be a squared image. Defaults to true
    public var onlySquareImagesFromCamera = true
    
    /// Enables selecting the front camera by default, useful for avatars. Defaults to false
    public var usesFrontCamera = false
    
    /// Adds a Filter step in the photo taking process.  Defaults to true
    public var showsPhotoFilters = true
    
    /// Adds a Video Trimmer step in the video taking process.  Defaults to true
    public var showsVideoTrimmer = true
    
    /// Enables you to opt out from saving new (or old but filtered) images to the
    /// user's photo library. Defaults to true.
    public var shouldSaveNewPicturesToAlbum = true
    
    /// Defines the name of the album when saving pictures in the user's photo library.
    /// In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName"
    public var albumName = "DefaultYPImagePickerAlbumName"

    /// Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
    /// Default value is `.photo`
    public var startOnScreen: YPPickerScreen = .photo
    
    /// Defines which screens are shown at launch, and their order.
    /// Default value is `[.library, .photo]`
    public var screens: [YPPickerScreen] = [.library, .photo]

    /// Adds a Crop step in the photo taking process, after filters.  Defaults to .none
    public var showsCrop: YPCropType = .none
    
    /// Controls the visibility of a grid on crop stage. Default it false
    public var showsCropGridOverlay = false
    
    /// Ex: cappedTo:1024 will make sure images from the library or the camera will be
    /// resized to fit in a 1024x1024 box. Defaults to original image size.
    public var targetImageSize = YPImageSize.original
    
    /// Adds a Overlay View to the camera
    public var overlayView: UIView?

    /// Defines if the navigation bar cancel button should be hidden when showing the picker. Default is false
    public var hidesCancelButton = false
    
    /// Defines if the status bar should be hidden when showing the picker. Default is true
    public var hidesStatusBar = true
    
    /// Defines if the bottom bar should be hidden when showing the picker. Default is false.
    public var hidesBottomBar = false

    /// Defines the preferredStatusBarAppearance
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    /// Defines the text colour to be shown when a bottom option is selected
    public var bottomMenuItemSelectedTextColour: UIColor = .ypLabel
    
    /// Defines the text colour to be shown when a bottom option is unselected
    public var bottomMenuItemUnSelectedTextColour: UIColor = .ypSecondaryLabel
    
    /// Defines the max camera zoom factor for camera. Disable camera zoom with 1. Default is 1.
    public var maxCameraZoomFactor: CGFloat = 1.0
    
    /// Adds an underline to each menu item.
    public var bottomMenuItemUnderline = false
    /// Controls the camera shutter sound. If set to true, the camera shutter sound will be disabled. Defaults to false.
    public var silentMode = false
    
    /// List of default filters which will be added on the filter screen
    public var filters: [YPFilter] = [
        YPFilter(name: "Normal", applier: nil),
        YPFilter(name: "Nashville", applier: YPFilter.nashvilleFilter),
        YPFilter(name: "Toaster", applier: YPFilter.toasterFilter),
        YPFilter(name: "1977", applier: YPFilter.apply1977Filter),
        YPFilter(name: "Clarendon", applier: YPFilter.clarendonFilter),
        YPFilter(name: "Vintage", applier: YPFilter.vintageFilter),
        YPFilter(name: "Dramatic", applier: YPFilter.dramaticFilter),
        YPFilter(name: "Warm", applier: YPFilter.warmFilter),
        YPFilter(name: "Cool", applier: YPFilter.coolFilter),
        YPFilter(name: "Vibrant", applier: YPFilter.vibrantFilter),
        YPFilter(name: "Dreamy", applier: YPFilter.dreamyFilter),
        YPFilter(name: "Sunset", applier: YPFilter.sunsetFilter),
        YPFilter(name: "Glow", applier: YPFilter.glowFilter),
        YPFilter(name: "Polaroid", applier: YPFilter.polaroidFilter),
        YPFilter(name: "Neon", applier: YPFilter.neonFilter),
        YPFilter(name: "Film", applier: YPFilter.filmFilter),
        YPFilter(name: "Retro", applier: YPFilter.retroFilter),
        YPFilter(name: "Minimal", applier: YPFilter.minimalFilter),
        YPFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        YPFilter(name: "Fade", coreImageFilterName: "CIPhotoEffectFade"),
        YPFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        YPFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        YPFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        YPFilter(name: "Tonal", coreImageFilterName: "CIPhotoEffectTonal"),
        YPFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
        YPFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        YPFilter(name: "Linear", coreImageFilterName: "CISRGBToneCurveToLinear"),
        YPFilter(name: "Sepia", coreImageFilterName: "CISepiaTone"),
        YPFilter(name: "XRay", coreImageFilterName: "CIXRay")
    ]
}

/// Encapsulates library specific settings.
public struct YPConfigLibrary {
    
    public var options: PHFetchOptions?

    /// Set this to true if you want to force the library output to be a squared image. Defaults to false.
    public var onlySquare = false
    
    /// Sets the cropping style to square or not. Ignored if `onlySquare` is true. Defaults to true.
    public var isSquareByDefault = true
    
    /// Hides crop button from showing but still allows for zooming.
    public var hideCropButton = false
    
	/// Minimum width, to prevent selectiong too high images. Have sense if onlySquare is true and the image is portrait.
    public var minWidthForItem: CGFloat?
    
    /// Choose what media types are available in the library. Defaults to `.photo`.
    /// If you define custom options PHFetchOptions var, than this will not work.
    public var mediaType = YPlibraryMediaType.photo

    /// Initial state of multiple selection button.
    public var defaultMultipleSelection = false

    /// Pre-selects the current item on setting multiple selection
    public var preSelectItemOnMultipleSelection = true

    /// Anything superior than 1 will enable the multiple selection feature.
    public var maxNumberOfItems = 1
    
    /// Anything greater than 1 will desactivate live photo and video modes (library only) and
    /// force users to select at least the number of items defined.
    public var minNumberOfItems = 1

    /// Set the number of items per row in collection view. Defaults to 4.
    public var numberOfItemsInRow: Int = 4

    /// Set the spacing between items in collection view. Defaults to 1.0.
    public var spacingBetweenItems: CGFloat = 1.0

    /// Allow to skip the selections gallery when selecting the multiple media items. Defaults to false.
    public var skipSelectionsGallery = false
    
    /// Allow to preselected media items
    public var preselectedItems: [YPMediaItem]?
    
    /// Set the overlay type shown on top of the selected library item
    public var itemOverlayType: YPItemOverlayType = .grid
    
    /// Sets the max zooming on a single photo or video
    public var maxZoomFactor = 6.0
}

/// Encapsulates video specific settings.
public struct YPConfigVideo {
    
    /** Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality
     - "AVAssetExportPresetLowQuality"
     - "AVAssetExportPreset640x480"
     - "AVAssetExportPresetMediumQuality"
     - "AVAssetExportPreset1920x1080"
     - "AVAssetExportPreset1280x720"
     - "AVAssetExportPresetHighestQuality"
     - "AVAssetExportPresetAppleM4A"
     - "AVAssetExportPreset3840x2160"
     - "AVAssetExportPreset960x540"
     - "AVAssetExportPresetPassthrough" // without any compression
     */
    public var compression: String = AVAssetExportPresetHighestQuality
    
    /// Choose the result video extension if you trim or compress a video. Defaults to mov.
    public var fileType: AVFileType = .mov
    
    /// Set this value for the `AVAssetExportSession` property `fileLengthLimit`
    /// May be useful for exporting video with original format `mp4`
    ///
    /// Sometimes `AVAssetExportSession` increase mp4 video bitrate
    /// so result file might be quite bigger than original from user gallery
    ///
    /// Usage example - setting `fileLengthLimit` to `10 MB`:
    /// ``` swift
    /// config.video.fileLengthLimit = 1048576 * 10
    /// ```
    /// For more information check [this thread](https://stackoverflow.com/questions/50560922/reducing-the-size-of-a-video-exported-with-avassetexportsession-ios-swift)
    public var fileLengthLimit: Int64?
    
    /// Defines the time limit for recording videos.
    /// Default is 60 seconds.
    public var recordingTimeLimit: TimeInterval = 60.0
    
    /// Defines the size limit in bytes for recording videos.
    /// If this property is not nil, then the recording percentage line tracks buy this.
    /// In bytes. 100000000 is 100 MB.
    /// AVCaptureMovieFileOutput.maxRecordedFileSize.
    public var recordingSizeLimit: Int64?

    /// Minimum free space when recording videos.
    /// AVCaptureMovieFileOutput.minFreeDiskSpaceLimit.
    public var minFreeDiskSpaceLimit: Int64 = 1024 * 1024
    
    /// Defines the time limit for videos from the library.
    /// Defaults to 60 seconds.
    public var libraryTimeLimit: TimeInterval = 60.0
    
    /// Defines the minimum time for the video
    /// Defaults to 3 seconds.
    public var minimumTimeLimit: TimeInterval = 3.0
    
    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    /// - Tag: trimmerMaxDuration
    public var trimmerMaxDuration: Double = 60.0
    
    /// The minimum duration allowed for the trimming.
    /// The handles won't pan further if the minimum duration is attained.
    public var trimmerMinDuration: Double = 3.0

    /// Defines if the user skips the trimer stage,
    /// the video will be trimmed automatically to the maximum value of trimmerMaxDuration.
    /// This case occurs when the user already has a video selected and enables a
    /// multiselection to pick more than one type of media (video or image),
    /// so, the trimmer step becomes optional.
    /// - SeeAlso: [trimmerMaxDuration](x-source-tag://trimmerMaxDuration)
    public var automaticTrimToTrimmerMaxDuration: Bool = false
    
    /// Hides the thumbnail selection functionality while keeping the video trimming.
    /// When set to true, users can trim videos but cannot select a custom thumbnail.
    /// The thumbnail will be automatically generated from the first frame of the trimmed video.
    /// Defaults to false.
    public var hideThumbnailSelection: Bool = false
}

/// Encapsulates gallery specific settings.
public struct YPConfigSelectionsGallery {
    /// Defines if the remove button should be hidden when showing the gallery. Default is true.
    public var hidesRemoveButton = true
}

public enum YPItemOverlayType {
    case none
    case grid
}

public enum YPlibraryMediaType {
    case photo
    case video
    case photoAndVideo
}
