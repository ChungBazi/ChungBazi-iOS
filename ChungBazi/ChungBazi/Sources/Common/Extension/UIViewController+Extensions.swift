//
//  UIViewController+Extensions.swift
//  ChungBazi
//
//  Created by 이현주 on 2/11/26.
//

import UIKit
import SnapKit

extension UIViewController {
    
    private static let loadingTag = 999999
    
    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 이미 있는지 확인
            if self.view.viewWithTag(Self.loadingTag) != nil {
                return
            }
            
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .gray
            spinner.tag = Self.loadingTag  // Tag 설정
            spinner.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(spinner)
            spinner.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            spinner.startAnimating()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Tag로 찾아서 제거
            if let spinner = self.view.viewWithTag(Self.loadingTag) as? UIActivityIndicatorView {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
            }
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
            return getVisibleViewController(from: navigationController.visibleViewController ?? vc)
        } else if let tabBarController = vc as? UITabBarController {
            return getVisibleViewController(from: tabBarController.selectedViewController ?? vc)
        } else if let presentedViewController = vc.presentedViewController {
            return getVisibleViewController(from: presentedViewController)
        }
        return vc
    }
}
