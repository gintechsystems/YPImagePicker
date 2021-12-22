//
//  YPBottomPagerView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPBottomPagerView: UIView {
    
    var header = YPPagerMenu()
    var scrollView = UIScrollView()
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .offWhiteOrBlack
        
        subviews(
            scrollView,
            header
        )
        
        layout(
            0,
            |scrollView|,
            0,
            |header| ~ 44
        )
        
        header.bottom(0)
        
        if (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20) {
            header.heightConstraint?.constant = (YPConfig.hidesBottomBar || (YPConfig.screens.count == 1)) ? 0 : 44 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        else {
            header.heightConstraint?.constant = (YPConfig.hidesBottomBar || (YPConfig.screens.count == 1)) ? 0 : 44
        }
        
        clipsToBounds = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
    }
}
