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
    
    public static func hazeRemovalFilter(image: CIImage) -> CIImage? {
        let filter = HazeRemovalFilter()
        filter.inputImage = image
        return filter.outputImage
    }
    
    public static func eightBitFilter(image: CIImage) -> CIImage? {
        let filter = EightBitFilter()
        filter.inputImage = image
        return filter.outputImage
    }
    
    public static func vhsLinesFilter(image: CIImage) -> CIImage? {
        let filter = VHSTrackingLinesFilter()
        filter.inputImage = image
        return filter.outputImage
    }
    
    public static func crtFilter(image: CIImage) -> CIImage? {
        let filter = CRTFilter()
        filter.inputImage = image
        return filter.outputImage
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

class HazeRemovalFilter: CIFilter {
    var inputImage: CIImage!
    var inputColor: CIColor! = CIColor(red: 0.7, green: 0.9, blue: 1.0)
    var inputDistance: Float! = 0.2
    var inputSlope: Float! = 0.0
    var hazeRemovalKernel: CIKernel!
    
    override init() {
        // check kernel has been already initialized
        let code: String = """
kernel vec4 myHazeRemovalKernel(
    sampler src,
    __color color,
    float distance,
    float slope)
{
    vec4 t;
    float d;

    d = destCoord().y * slope + distance;
    t = unpremultiply(sample(src, samplerCoord(src)));
    t = (t - d * color) / (1.0 - d);

    return premultiply(t);
}
"""
        self.hazeRemovalKernel = CIKernel(source: code)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        guard let inputImage = self.inputImage,
            let hazeRemovalKernel = self.hazeRemovalKernel,
            let inputColor = self.inputColor,
            let inputDistance = self.inputDistance,
            let inputSlope = self.inputSlope
            else {
                return nil
        }
        let src: CISampler = CISampler(image: inputImage)
        return hazeRemovalKernel.apply(extent: inputImage.extent,
            roiCallback: { (_, rect) -> CGRect in
                return rect
        }, arguments: [
            src,
            inputColor,
            inputDistance,
            inputSlope
            ])
    }
    
    override var attributes: [String: Any] {
        return [
            kCIAttributeFilterDisplayName: "Haze Removal Filter",
            "inputDistance": [
                kCIAttributeMin: 0.0,
                kCIAttributeMax: 1.0,
                kCIAttributeSliderMin: 0.0,
                kCIAttributeSliderMax: 0.7,
                kCIAttributeDefault: 0.2,
                kCIAttributeIdentity: 0.0,
                kCIAttributeType: kCIAttributeTypeScalar
            ],
            "inputSlope": [
                kCIAttributeSliderMin: -0.01,
                kCIAttributeSliderMax: 0.01,
                kCIAttributeDefault: 0.00,
                kCIAttributeIdentity: 0.00,
                kCIAttributeType: kCIAttributeTypeScalar
            ],
            kCIInputColorKey: [
                kCIAttributeDefault: CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ]
        ]
    }
}

class EightBitFilter: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputPaletteIndex: CGFloat = 4
    @objc var inputScale: CGFloat = 8
    
    override func setDefaults()
    {
        inputPaletteIndex = 4
        inputScale = 8
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Eight Bit" as AnyObject,
            
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            
            "inputPaletteIndex": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 4,
                kCIAttributeDescription: "0: Spectrum (Dim). 1: Spectrum (Bright). 2: VIC-20. 3: C-64. 4: Apple II ",
                kCIAttributeDisplayName: "Palette Index",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 4,
                kCIAttributeType: kCIAttributeTypeInteger],
            
            "inputScale": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Scale",
                kCIAttributeMin: 1,
                kCIAttributeSliderMin: 1,
                kCIAttributeSliderMax: 100,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let paletteIndex = max(min(EightBitFilter.palettes.count - 1, Int(inputPaletteIndex)), 0)
        
        let palette = EightBitFilter.palettes[paletteIndex]
        
        var kernelString = "kernel vec4 thresholdFilter(sampler image)"
        kernelString += "{ \n"
        kernelString += "   vec4 uv = sample(image,samplerCoord(image)); \n"
        kernelString += "   float dist = distance(uv.rgb, \(palette.first!.toVectorString())); \n"
        kernelString += "   vec3 returnColor = \(palette.first!.toVectorString());\n "
        
        for paletteColor in palette where paletteColor != palette.first!
        {
            kernelString += "if (distance(uv.rgb, \(paletteColor.toVectorString())) < dist) \n"
            kernelString += "{ \n"
            kernelString += "   dist = distance(uv.rgb, \(paletteColor.toVectorString())); \n"
            kernelString += "   returnColor = \(paletteColor.toVectorString()); \n"
            kernelString += "} \n"
        }
        
        kernelString += "   return vec4(returnColor, 1.0) ; \n"
        kernelString += "} \n"
        
        guard let kernel = CIKernel(source: kernelString) else
        {
            return nil
        }

        let extent = inputImage.extent
        
        
        let final = kernel.apply(extent: extent,
                                roiCallback: {
                                        (index, rect) in
                                        return rect
                                    },
                                arguments: [inputImage.applyingFilter("CIPixellate", parameters: [kCIInputScaleKey: inputScale])])
        
        return final
    }

    // MARK: Palettes
    // ZX Spectrum Dim
    
    static let dimSpectrumColors = [
        RGB(r: 0x00, g: 0x00, b: 0x00),
        RGB(r: 0x00, g: 0x00, b: 0xCD),
        RGB(r: 0xCD, g: 0x00, b: 0x00),
        RGB(r: 0xCD, g: 0x00, b: 0xCD),
        RGB(r: 0x00, g: 0xCD, b: 0x00),
        RGB(r: 0x00, g: 0xCD, b: 0xCD),
        RGB(r: 0xCD, g: 0xCD, b: 0x00),
        RGB(r: 0xCD, g: 0xCD, b: 0xCD)]
    
    // ZX Spectrum Bright
    
    static let brightSpectrumColors = [
        RGB(r: 0x00, g: 0x00, b: 0x00),
        RGB(r: 0x00, g: 0x00, b: 0xFF),
        RGB(r: 0xFF, g: 0x00, b: 0x00),
        RGB(r: 0xFF, g: 0x00, b: 0xFF),
        RGB(r: 0x00, g: 0xFF, b: 0x00),
        RGB(r: 0x00, g: 0xFF, b: 0xFF),
        RGB(r: 0xFF, g: 0xFF, b: 0x00),
        RGB(r: 0xFF, g: 0xFF, b: 0xFF)]
    
    
    // VIC-20
    static let vic20Colors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 255, g: 255, b: 255),
        RGB(r: 141, g: 62, b: 55),
        RGB(r: 114, g: 193, b: 200),
        RGB(r: 128, g: 52, b: 139),
        RGB(r: 85, g: 160, b: 73),
        RGB(r: 64, g: 49, b: 141),
        RGB(r: 170, g: 185, b: 93),
        RGB(r: 139, g: 84, b: 41),
        RGB(r: 213, g: 159, b: 116),
        RGB(r: 184, g: 105, b: 98),
        RGB(r: 135, g: 214, b: 221),
        RGB(r: 170, g: 95, b: 182),
        RGB(r: 148, g: 224, b: 137),
        RGB(r: 128, g: 113, b: 204),
        RGB(r: 191, g: 206, b: 114)
    ]
    
    
    // C-64
    
    static let c64Colors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 255, g: 255, b: 255),
        RGB(r: 136, g: 57, b: 50),
        RGB(r: 103, g: 182, b: 189),
        RGB(r: 139, g: 63, b: 150),
        RGB(r: 85, g: 160, b: 73),
        RGB(r: 64, g: 49, b: 141),
        RGB(r: 191, g: 206, b: 114),
        RGB(r: 139, g: 84, b: 41),
        RGB(r: 87, g: 66, b: 0),
        RGB(r: 184, g: 105, b: 98),
        RGB(r: 80, g: 80, b: 80),
        RGB(r: 120, g: 120, b: 120),
        RGB(r: 148, g: 224, b: 137),
        RGB(r: 120, g: 105, b: 196),
        RGB(r: 159, g: 159, b: 159)
    ]
    
    
    // Apple II
    static let appleIIColors = [
        RGB(r: 0, g: 0, b: 0),
        RGB(r: 114, g: 38, b: 64),
        RGB(r: 64, g: 51, b: 127),
        RGB(r: 228, g: 52, b: 254),
        RGB(r: 14, g: 89, b: 64),
        RGB(r: 128, g: 128, b: 128),
        RGB(r: 27, g: 154, b: 254),
        RGB(r: 191, g: 179, b: 255),
        RGB(r: 64, g: 76, b: 0),
        RGB(r: 228, g: 101, b: 1),
        RGB(r: 128, g: 128, b: 128),
        RGB(r: 241, g: 166, b: 191),
        RGB(r: 27, g: 203, b: 1),
        RGB(r: 191, g: 204, b: 128),
        RGB(r: 141, g: 217, b: 191),
        RGB(r: 255, g: 255, b: 255)
    ]
    
    static let palettes = [dimSpectrumColors, brightSpectrumColors, vic20Colors, c64Colors, appleIIColors]
}

class VHSTrackingLinesFilter: CIFilter
{
    @objc var inputImage: CIImage?
    @objc var inputTime: CGFloat = 0
    @objc var inputSpacing: CGFloat = 50
    @objc var inputStripeHeight: CGFloat = 0.5
    @objc var inputBackgroundNoise: CGFloat = 0.05
    
    override func setDefaults()
    {
        inputSpacing = 50
        inputStripeHeight = 0.5
        inputBackgroundNoise = 0.05
    }
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "VHS Tracking Lines" as AnyObject,
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputTime": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Time",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 2048,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputSpacing": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 50,
                kCIAttributeDisplayName: "Spacing",
                kCIAttributeMin: 20,
                kCIAttributeSliderMin: 20,
                kCIAttributeSliderMax: 200,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputStripeHeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.5,
                kCIAttributeDisplayName: "Stripe Height",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 1,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputBackgroundNoise": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0.05,
                kCIAttributeDisplayName: "Background Noise",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 0.25,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    override var outputImage: CIImage?
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let tx = NSValue(cgAffineTransform: CGAffineTransform(translationX: CGFloat(drand48() * 100), y: CGFloat(drand48() * 100)))
        
        let noise = CIFilter(name: "CIRandomGenerator")!.outputImage!
            .applyingFilter("CIAffineTransform",
                parameters: [kCIInputTransformKey: tx])
            .applyingFilter("CILanczosScaleTransform",
                parameters: [kCIInputAspectRatioKey: 5])
            .cropped(to: inputImage.extent)
        
        
        let kernel = CIColorKernel(source:
            "kernel vec4 thresholdFilter(__sample image, __sample noise, float time, float spacing, float stripeHeight, float backgroundNoise)" +
                "{" +
                "   vec2 uv = destCoord();" +
                
                "   float stripe = smoothstep(1.0 - stripeHeight, 1.0, sin((time + uv.y) / spacing)); " +
                
                "   return image + (noise * noise * stripe) + (noise * backgroundNoise);" +
            "}"
            )!
        
        
        let extent = inputImage.extent
        let arguments = [inputImage, noise, inputTime, inputSpacing, inputStripeHeight, inputBackgroundNoise] as [Any]
        
        let final = kernel.apply(extent: extent, arguments: arguments)?
            .applyingFilter("CIPhotoEffectNoir", parameters: [:])
        
        return final
    }
}

class CRTFilter: CIFilter
{
    @objc var inputImage : CIImage?
    @objc var inputPixelWidth: CGFloat = 8
    @objc var inputPixelHeight: CGFloat = 12
    @objc var inputBend: CGFloat = 3.2
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "CRT Filter" as AnyObject,
            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
            "inputPixelWidth": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 8,
                kCIAttributeDisplayName: "Pixel Width",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputPixelHeight": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 12,
                kCIAttributeDisplayName: "Pixel Height",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 20,
                kCIAttributeType: kCIAttributeTypeScalar],
            "inputBend": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 3.2,
                kCIAttributeDisplayName: "Bend",
                kCIAttributeMin: 0.5,
                kCIAttributeSliderMin: 0.5,
                kCIAttributeSliderMax: 10,
                kCIAttributeType: kCIAttributeTypeScalar]
        ]
    }
    
    let crtWarpFilter = CRTWarpFilter()
    let crtColorFilter = CRTColorFilter()
    
    let vignette = CIFilter(name: "CIVignette",
                            parameters: [
            kCIInputIntensityKey: 1.5,
            kCIInputRadiusKey: 2])!
    
    override func setDefaults()
    {
        inputPixelWidth = 8
        inputPixelHeight = 12
        inputBend = 3.2
    }
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        crtColorFilter.pixelHeight = inputPixelHeight
        crtColorFilter.pixelWidth = inputPixelWidth
        crtWarpFilter.bend =  inputBend
        
        crtColorFilter.inputImage = inputImage
        vignette.setValue(crtColorFilter.outputImage,
            forKey: kCIInputImageKey)
        crtWarpFilter.inputImage = vignette.outputImage!
        
        return crtWarpFilter.outputImage
    }
    
    class CRTColorFilter: CIFilter
    {
        @objc var inputImage : CIImage?
        
        var pixelWidth: CGFloat = 8.0
        var pixelHeight: CGFloat = 12.0
        
        let crtColorKernel = CIKernel(source:
            "kernel vec4 crtColor(sampler image, float pixelWidth, float pixelHeight) \n" +
                "{ \n" +
                
                "   int columnIndex = int(mod(samplerCoord(image).x / pixelWidth, 3.0)); \n" +
                "   int rowIndex = int(mod(samplerCoord(image).y, pixelHeight)); \n" +
                "   float sampleRed = sample(image,samplerCoord(image)).r; \n" +
                "   float sampleGreen = sample(image,samplerCoord(image)).g; \n" +
                "   float sampleBlue = sample(image,samplerCoord(image)).b; \n" +
                "   float scanlineMultiplier = (rowIndex == 0 || rowIndex == 1) ? 0.3 : 1.0;" +
                
                "   float red = (columnIndex == 0) ? sampleRed : sampleRed * ((columnIndex == 2) ? 0.3 : 0.2); " +
                "   float green = (columnIndex == 1) ? sampleGreen : sampleGreen * ((columnIndex == 2) ? 0.3 : 0.2); " +
                "   float blue = (columnIndex == 2) ? sampleBlue : sampleBlue * 0.2; " +
                "   return vec4(red * scanlineMultiplier, green * scanlineMultiplier, blue * scanlineMultiplier, 1.0); \n" +
            "}"
        )
        
        
        override var outputImage: CIImage!
        {
            if let inputImage = inputImage,
                let crtColorKernel = crtColorKernel
            {
                let dod = inputImage.extent
                let args = [inputImage, pixelWidth, pixelHeight] as [Any]
                return crtColorKernel.apply(extent: dod,
                                roiCallback: {
                                    (index, rect) in
                                    return rect
                                    },
                                arguments: args)
            }
            return nil
        }
    }
    
    class CRTWarpFilter: CIFilter
    {
        @objc var inputImage : CIImage?
        var bend: CGFloat = 3.2
        
        let crtWarpKernel = CIWarpKernel(source:
            "kernel vec2 crtWarp(vec2 extent, float bend)" +
                "{" +
                "   vec2 coord = ((destCoord() / extent) - 0.5) * 2.0;" +
                
                "   coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);" +
                "   coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);" +
                
                "   coord  = ((coord / 2.0) + 0.5) * extent;" +
                
                "   return coord;" +
            "}"
        )
        
        override var outputImage : CIImage!
            {
                if let inputImage = inputImage,
                    let crtWarpKernel = crtWarpKernel
                {
                    let arguments = [CIVector(x: inputImage.extent.size.width, y: inputImage.extent.size.height), bend] as [Any]
                    let extent = inputImage.extent.insetBy(dx: -1, dy: -1)
                    
                    return crtWarpKernel.apply(extent: extent,
                        roiCallback:
                        {
                            (index, rect) in
                            return rect
                        },
                        image: inputImage,
                        arguments: arguments)
                }
                return nil
        }
    }
}

struct RGB: Equatable
{
    let r:UInt8
    let g:UInt8
    let b:UInt8
    
    func toVectorString() -> String
    {
        return "vec3(\(Double(self.r) / 255), \(Double(self.g) / 255), \(Double(self.b) / 255))"
    }
}

func ==(lhs: RGB, rhs: RGB) -> Bool
{
    return lhs.toVectorString() == rhs.toVectorString()
}

