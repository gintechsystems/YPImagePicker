//
//  YPPagerMenu.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPPagerMenu: UIView {
    
    var didSetConstraints = false
    var menuItems = [YPMenuItem]()
    
    private var gradientLayer: CAGradientLayer!
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .offWhiteOrBlack
        clipsToBounds = true
    }
    
    var separators = [UIView]()
    
    func setUpMenuItemsConstraints() {
        let screenWidth = YPImagePickerConfiguration.screenWidth
        let menuItemWidth: CGFloat = screenWidth / CGFloat(menuItems.count)
        var previousMenuItem: YPMenuItem?
        for m in menuItems {
            sv(
                m
            )
            
            m.fillVertically().width(menuItemWidth)
            if let pm = previousMenuItem {
                pm-0-m
            } else {
                |m
            }
            
            previousMenuItem = m
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if !didSetConstraints {
            setUpMenuItemsConstraints()
        }
        didSetConstraints = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (YPImagePickerConfiguration.shared.colors.gradientColor.count > 1) {
            setGradientBackground()
        }
    }
    
    func refreshMenuItems() {
        didSetConstraints = false
        updateConstraints()
    }
    
    private func setGradientBackground() {
        if (gradientLayer == nil) {
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = YPImagePickerConfiguration.shared.colors.gradientColor.map({ $0.cgColor })
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = self.bounds

            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
