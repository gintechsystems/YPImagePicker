//
//  YPMenuItem.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPMenuItem: UIView {
    
    var textLabel = UILabel()
    var button = UIButton()
    var underline = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }

    func setup() {
        backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemBackgroundColor
        
        if (YPImagePickerConfiguration.shared.bottomMenuItemUnderline) {
            sv(
                textLabel,
                button,
                underline
            )
        }
        else {
            sv(
                textLabel,
                button
            )
        }
        
        if (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20) {
            textLabel.centerHorizontally()
            textLabel.top(10)
            
            button.fillHorizontally()
        }
        else {
            textLabel.centerInContainer()
            
            button.fillContainer()
        }
        
        if (YPImagePickerConfiguration.shared.bottomMenuItemUnderline) {
            underline.backgroundColor = .clear
            underline.fillHorizontally(m: 20)
            underline.height(2)
            
            underline.Top == button.Bottom + 10
        }
        
        |-(10)-textLabel-(10)-|
        
        textLabel.style { l in
            l.textAlignment = .center
            l.font = YPConfig.fonts.menuItemFont
            l.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
            l.adjustsFontSizeToFitWidth = true
            l.numberOfLines = 2
        }
    }

    func select() {
        textLabel.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemSelectedTextColor
        underline.backgroundColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnderlineColor
    }
    
    func deselect() {
        textLabel.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
        underline.backgroundColor = .clear
    }
}
