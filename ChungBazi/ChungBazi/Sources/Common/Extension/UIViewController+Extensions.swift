//
//  UIViewController+Extensions.swift
//  ChungBazi
//
//  Created by 이현주 on 2/11/26.
//

import UIKit
import SnapKit

extension UIViewController {
    
    private enum AssociatedKey {
        static var spinner: Void?
    }

    
    private var spinner: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.spinner) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.spinner, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 이미 spinner가 있으면 재사용
            if let existingSpinner = self.spinner {
                existingSpinner.startAnimating()
                return
            }
            
            // 새 spinner 생성
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .gray
            spinner.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(spinner)
            spinner.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            spinner.startAnimating()
            self.spinner = spinner
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.spinner?.stopAnimating()
            self.spinner?.removeFromSuperview()
            self.spinner = nil
        }
    }
    
    // ViewController의 이름을 반환
    var screenName: String {
        return String(describing: type(of: self))
    }
    
    // 현재 최상위 ViewController 가져오기
    static func getCurrentViewController() -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            return getVisibleViewController(from: rootViewController)
        }
        return nil
    }
    
    // 실제로 보이는 ViewController 찾기
    private static func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController {
            guard let visible = navigationController.visibleViewController else { return vc }
            return getVisibleViewController(from: visible)
        } else if let tabBarController = vc as? UITabBarController {
            guard let selected = tabBarController.selectedViewController else { return vc }
            return getVisibleViewController(from: selected)
        } else if let presentedViewController = vc.presentedViewController {
            return getVisibleViewController(from: presentedViewController)
        }
        return vc
    }
}
