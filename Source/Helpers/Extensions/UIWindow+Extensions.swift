//
//  UIWindow+Extensions.swift
//  YPImagePicker
//
//  Created by Joe Ginley on 6/28/25.
//  Copyright © 2025 Yummypets. All rights reserved.
//

import UIKit

extension UIWindow {
    
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
    
}
