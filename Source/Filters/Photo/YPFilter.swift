//
//  YPFilter.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit
import CoreImage

public typealias FilterApplierType = ((_ image: CIImage) -> CIImage?)

public struct YPFilter {
    var name = ""
    var applier: FilterApplierType?
    
    public init(name: String, coreImageFilterName: String) {
        self.name = name
        self.applier = YPFilter.coreImageFilter(name: coreImageFilterName)
    }
    
    public init(name: String, applier: FilterApplierType?) {
        self.name = name
        self.applier = applier
    }
}

extension YPFilter {
    public static func coreImageFilter(name: String) -> FilterApplierType {
        return { (image: CIImage) -> CIImage? in
            let filter = CIFilter(name: name)
            filter?.setValue(image, forKey: kCIInputImageKey)
            return filter?.outputImage!
        }
    }
    
    public static func clarendonFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(red: 127, green: 187, blue: 227, alpha: Int(255 * 0.2),
                                            rect: foregroundImage.extent)
        return foregroundImage.applyingFilter("CIOverlayBlendMode", parameters: [
            "inputBackgroundImage": backgroundImage
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.35,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
                ])
    }
    
    public static func nashvilleFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56),
                                            rect: foregroundImage.extent)
        let backgroundImage2 = getColorImage(red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4),
                                             rect: foregroundImage.extent)
        return foregroundImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
                ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1
                ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2
                ])
    }
    
    public static func apply1977Filter(ciImage: CIImage) -> CIImage? {
        let filterImage = getColorImage(red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1), rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3
                ])
        return filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1)
                ])
    }
    
    public static func toasterFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = self.getColor(red: 128, green: 78, blue: 15, alpha: 255)
        let color1 = self.getColor(red: 79, green: 0, blue: 79, alpha: 255)
        let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.1
                ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!
                ])
    }
    
    public static func vintageFilter(ciImage: CIImage) -> CIImage? {
        let overlayImage = getColorImage(red: 255, green: 225, blue: 80, alpha: Int(255 * 0.07), rect: ciImage.extent)
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.8,
                "inputBrightness": 0.1,
                "inputContrast": 1.15
                ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.6
                ])
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": overlayImage
                ])
            .applyingFilter("CIVignette", parameters: [
                "inputIntensity": 0.4,
                "inputRadius": 1.0
                ])
    }
    
    public static func dramaticFilter(ciImage: CIImage) -> CIImage? {
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.4,
                "inputBrightness": -0.1,
                "inputContrast": 1.3
                ])
            .applyingFilter("CISharpenLuminance", parameters: [
                "inputSharpness": 0.8
                ])
            .applyingFilter("CIVignette", parameters: [
                "inputIntensity": 0.6,
                "inputRadius": 0.8
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.15),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.85),
                "inputPoint4": CIVector(x: 1, y: 1)
                ])
    }
    
    public static func warmFilter(ciImage: CIImage) -> CIImage? {
        let warmOverlay = getColorImage(red: 255, green: 140, blue: 0, alpha: Int(255 * 0.15), rect: ciImage.extent)
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.05
                ])
            .applyingFilter("CIWhitePointAdjust", parameters: [
                "inputColor": CIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
                ])
            .applyingFilter("CISoftLightBlendMode", parameters: [
                "inputBackgroundImage": warmOverlay
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.05
                ])
    }
    
    public static func coolFilter(ciImage: CIImage) -> CIImage? {
        let coolOverlay = getColorImage(red: 0, green: 140, blue: 255, alpha: Int(255 * 0.12), rect: ciImage.extent)
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.15,
                "inputBrightness": 0.02,
                "inputContrast": 1.08
                ])
            .applyingFilter("CIWhitePointAdjust", parameters: [
                "inputColor": CIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
                ])
            .applyingFilter("CISoftLightBlendMode", parameters: [
                "inputBackgroundImage": coolOverlay
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": -0.05
                ])
    }
    
    public static func vibrantFilter(ciImage: CIImage) -> CIImage? {
        return ciImage
            .applyingFilter("CIVibrance", parameters: [
                "inputAmount": 1.5
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.08,
                "inputContrast": 1.15
                ])
            .applyingFilter("CIUnsharpMask", parameters: [
                "inputRadius": 2.5,
                "inputIntensity": 0.5
                ])
            .applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputHighlightAmount": 0.75,
                "inputShadowAmount": 1.25
                ])
    }
    
    public static func dreamyFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 6.0, height / 6.0)
        let radius1 = min(width / 1.2, height / 1.2)
        
        let color0 = getColor(red: 255, green: 192, blue: 203, alpha: 120) // Light pink
        let color1 = getColor(red: 255, green: 255, blue: 255, alpha: 0)   // Transparent white
        let dreamGradient = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIGaussianBlur", parameters: [
                "inputRadius": 0.8
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.9,
                "inputBrightness": 0.15,
                "inputContrast": 0.9
                ])
            .applyingFilter("CISoftLightBlendMode", parameters: [
                "inputBackgroundImage": dreamGradient!
                ])
            .applyingFilter("CIExposureAdjust", parameters: [
                "inputEV": 0.3
                ])
    }
    
    // MARK: - Additional Cool Filters
    
    public static func sunsetFilter(ciImage: CIImage) -> CIImage? {
        let sunsetOverlay = getColorImage(red: 255, green: 94, blue: 77, alpha: Int(255 * 0.2), rect: ciImage.extent)
        let warmGlow = getColorImage(red: 255, green: 165, blue: 0, alpha: Int(255 * 0.1), rect: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.4,
                "inputBrightness": 0.1,
                "inputContrast": 1.2
                ])
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": sunsetOverlay
                ])
            .applyingFilter("CISoftLightBlendMode", parameters: [
                "inputBackgroundImage": warmGlow
                ])
            .applyingFilter("CIVignette", parameters: [
                "inputIntensity": 0.3,
                "inputRadius": 1.2
                ])
    }
    
    public static func glowFilter(ciImage: CIImage) -> CIImage? {
        let result = ciImage
            .applyingFilter("CIGaussianBlur", parameters: [
                "inputRadius": 1.5
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.1,
                "inputBrightness": 0.2,
                "inputContrast": 0.9
                ])
            .applyingFilter("CIBloom", parameters: [
                "inputRadius": 10.0,
                "inputIntensity": 0.8
                ])
            .applyingFilter("CIExposureAdjust", parameters: [
                "inputEV": 0.4
                ])
        
        // Crop to original extent to prevent thumbnail sizing issues
        return result.cropped(to: ciImage.extent)
    }
    
    public static func polaroidFilter(ciImage: CIImage) -> CIImage? {
        let yellowTint = getColorImage(red: 255, green: 240, blue: 200, alpha: Int(255 * 0.15), rect: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.7,
                "inputBrightness": 0.15,
                "inputContrast": 1.25
                ])
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": yellowTint
                ])
            .applyingFilter("CIVignette", parameters: [
                "inputIntensity": 0.7,
                "inputRadius": 0.9
                ])
            .applyingFilter("CINoiseReduction", parameters: [
                "inputNoiseLevel": 0.02,
                "inputSharpness": 0.4
                ])
    }
    
    public static func neonFilter(ciImage: CIImage) -> CIImage? {
        let neonOverlay = getColorImage(red: 255, green: 20, blue: 147, alpha: Int(255 * 0.08), rect: ciImage.extent)
        
        let result = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.6,
                "inputBrightness": 0.05,
                "inputContrast": 1.4
                ])
            .applyingFilter("CIUnsharpMask", parameters: [
                "inputRadius": 2.0,
                "inputIntensity": 1.2
                ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": neonOverlay
                ])
            .applyingFilter("CIBloom", parameters: [
                "inputRadius": 8.0,
                "inputIntensity": 0.5
                ])
        
        // Crop to original extent to prevent thumbnail sizing issues
        return result.cropped(to: ciImage.extent)
    }
    
    public static func filmFilter(ciImage: CIImage) -> CIImage? {
        let filmGrain = getColorImage(red: 120, green: 120, blue: 120, alpha: Int(255 * 0.05), rect: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.85,
                "inputBrightness": 0.08,
                "inputContrast": 1.15
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0.05),
                "inputPoint1": CIVector(x: 0.25, y: 0.22),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.78),
                "inputPoint4": CIVector(x: 1, y: 0.95)
                ])
            .applyingFilter("CIOverlayBlendMode", parameters: [
                "inputBackgroundImage": filmGrain
                ])
            .applyingFilter("CIVignette", parameters: [
                "inputIntensity": 0.25,
                "inputRadius": 1.5
                ])
    }
    
    public static func retroFilter(ciImage: CIImage) -> CIImage? {
        let retroOverlay = getColorImage(red: 255, green: 200, blue: 100, alpha: Int(255 * 0.12), rect: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.1,
                "inputBrightness": 0.12,
                "inputContrast": 1.3
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.15
                ])
            .applyingFilter("CISoftLightBlendMode", parameters: [
                "inputBackgroundImage": retroOverlay
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0.1),
                "inputPoint1": CIVector(x: 0.25, y: 0.3),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.7),
                "inputPoint4": CIVector(x: 1, y: 0.9)
                ])
    }
    
    public static func minimalFilter(ciImage: CIImage) -> CIImage? {
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 0.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.1
                ])
            .applyingFilter("CIExposureAdjust", parameters: [
                "inputEV": 0.2
                ])
            .applyingFilter("CIHighlightShadowAdjust", parameters: [
                "inputHighlightAmount": 0.8,
                "inputShadowAmount": 1.1
                ])
            .applyingFilter("CIUnsharpMask", parameters: [
                "inputRadius": 1.0,
                "inputIntensity": 0.3
                ])
    }
    
    private static func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        return CIColor(red: CGFloat(Double(red) / 255.0),
                       green: CGFloat(Double(green) / 255.0),
                       blue: CGFloat(Double(blue) / 255.0),
                       alpha: CGFloat(Double(alpha) / 255.0))
    }
    
    private static func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = self.getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
}
