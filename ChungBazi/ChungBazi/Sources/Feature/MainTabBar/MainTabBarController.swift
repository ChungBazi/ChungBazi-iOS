//
//  MainTabBarController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit
import SnapKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarUI()
        setupViewControllers()
        configureTabBarItemFonts()
    }
    
    private func createHomeViewController() -> UIViewController {
        return createNavigationController(for: HomeViewController(), title: "홈", image: .tabHomeIcon, tag: 0)
    }
    
    private func createCalendarViewController() -> UIViewController {
        return createNavigationController(for: CalenderViewController(), title: "캘린더", image: .tabCalendarIcon, tag: 1)
    }
    
    private func createCommunityViewController() -> UIViewController {
        return createNavigationController(for: UIViewController(), title: "커뮤니티", image: .tabCommunityIcon, tag: 2)
    }
    
    private func createProfileViewController() -> UIViewController {
        return createNavigationController(for: ProfileViewController(), title: "프로필", image: .tabProfileIcon, tag: 3)
    }
    
    private func createNavigationController(for viewController: UIViewController, title: String, image: UIImage?, tag: Int) -> UINavigationController {
        let tabBarItem = createTabBarItem(title: title, image: image, tag: tag)
        viewController.tabBarItem = tabBarItem
        return UINavigationController(rootViewController: viewController)
    }
    
    private func setTabBarUI() {
        let customTabbar = CustomTabBar()
        setValue(customTabbar, forKey: "tabBar")

        tabBar.tintColor = .blue700
        tabBar.unselectedItemTintColor = .gray800

        configureTabBarItemFonts()
    }

    private func configureTabBarItemFonts() {
        let selectedFont = UIFont.ptdMediumFont(ofSize: 12)
        let unselectedFont = UIFont.ptdMediumFont(ofSize: 12)

        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: selectedFont,
            .foregroundColor: UIColor.blue700
        ]
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            .font: unselectedFont,
            .foregroundColor: UIColor.gray800
        ]

        for viewController in viewControllers ?? [] {
            if let tabBarItem = viewController.tabBarItem {
                tabBarItem.setTitleTextAttributes(unselectedAttributes, for: .normal)
                tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
            }
        }
    }
    
    private func createTabBarItem(title: String, image: UIImage?, tag: Int) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 3)
        
        return tabBarItem
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createHomeViewController(),
            createCalendarViewController(),
            createCommunityViewController(),
            createProfileViewController(),
        ]
    }
    
    private class CustomTabBar: UITabBar {
        private var backgroundView = UIView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard let superview = self.superview else { return }
            
            let safeAreaBottom = superview.safeAreaInsets.bottom
            var newFrame = frame
            newFrame.size.height = Constants.tabBarHeight + safeAreaBottom
            newFrame.origin.y = superview.bounds.height - newFrame.size.height
            frame = newFrame
            
            let roundedPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 10, height: 10)
            )
            let maskLayer = CAShapeLayer()
            maskLayer.path = roundedPath.cgPath
            layer.mask = maskLayer
            
            backgroundColor = .white
        }
    }
}
