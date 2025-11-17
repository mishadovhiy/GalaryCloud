//
//  UIWindow.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import UIKit

extension UIApplication {
    var activeWindow: UIWindow? {
        if let windowScene = self.connectedScenes
            .first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene {
            
            if let keyWindow = windowScene.windows.first(where: {
                $0.isKeyWindow
            }) {
                return keyWindow
            }
        }
        return UIApplication.shared.keyWindow
    }
}

extension UIViewController {
    var topViewController: UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topViewController
        }
        return self
    }
}
