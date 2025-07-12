//
//  UIView+Extensions.swift
//  YPImagePicker
//
//  Created by Joe Ginley on 7/12/25.
//  Copyright © 2025 Yummypets. All rights reserved.
//

import UIKit

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
