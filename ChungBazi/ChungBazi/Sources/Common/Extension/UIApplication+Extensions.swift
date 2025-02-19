//
//  UIApplication+Extensions.swift
//  ChungBazi
//
//  Created by 이현주 on 2/19/25.
//

import UIKit

extension UIApplication {
    static func getMostTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getMostTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getMostTopViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getMostTopViewController(base: presented)
        }
        return base
    }
}
