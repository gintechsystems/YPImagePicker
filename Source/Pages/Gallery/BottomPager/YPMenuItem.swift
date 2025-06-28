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
            subviews(
                textLabel,
                button,
                underline
            )
        }
        else {
            subviews(
                textLabel,
                button
            )
        }
        
        if (UIWindow.current?.safeAreaInsets.top ?? 0 > 20) {
            textLabel.centerHorizontally()
            textLabel.top(10)
            
            button.fillHorizontally()
        }
        else {
            textLabel.centerInContainer()
            
            button.fillContainer()
        }
        
        |-(10)-textLabel-(10)-|
        
        textLabel.style { l in
            l.textAlignment = .center
            l.font = YPConfig.fonts.menuItemFont
            l.textColor = YPImagePickerConfiguration.shared.colors.bottomMenuItemUnselectedTextColor
            l.adjustsFontSizeToFitWidth = true
            l.numberOfLines = 2
        }
        
        if (YPImagePickerConfiguration.shared.bottomMenuItemUnderline) {
            // Since we don't know the text yet we can't calculate the width until the item is added later.
            underline.backgroundColor = .clear
            underline.height(2)
            
            if (UIWindow.current?.safeAreaInsets.top ?? 0 > 20) {
                underline.Top == button.Bottom + 8
            }
            else {
                underline.Top == button.Bottom - 8
            }
        }
    }
    
    func sizeUnderline() {
        let textSize = textLabel.text!.boundingRect(with: textLabel.bounds.size, options: .usesLineFragmentOrigin, attributes: [.font : textLabel.font!], context: nil)
        
        underline.width(ceil(textSize.width) + 10)
        underline.centerHorizontally()
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
