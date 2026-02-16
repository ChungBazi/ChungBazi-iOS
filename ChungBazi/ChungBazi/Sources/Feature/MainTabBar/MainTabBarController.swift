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
        setupTabBar()
        setupViewControllers()
        configureTabBarItemFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Setup Methods
    
    private func setupTabBar() {
        let customTabBar = CustomTabBar()
        setValue(customTabBar, forKey: "tabBar")

        tabBar.tintColor = .blue700
        tabBar.unselectedItemTintColor = .gray800
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createNavigationController(for: HomeViewController(), title: "홈", image: .tabHomeIcon, tag: 0),
            createNavigationController(for: CalenderViewController(), title: "캘린더", image: .tabCalendarIcon, tag: 1),
//            createNavigationController(for: CommunityViewController(), title: "커뮤니티", image: .tabCommunityIcon, tag: 2),
            createNavigationController(for: ProfileViewController(), title: "프로필", image: .tabProfileIcon, tag: 2)
        ]
    }
    
    private func configureTabBarItemFonts() {
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ptdMediumFont(ofSize: 12),
            .foregroundColor: UIColor.blue700
        ]
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ptdMediumFont(ofSize: 12),
            .foregroundColor: UIColor.gray800
        ]

        viewControllers?.forEach { viewController in
            viewController.tabBarItem.setTitleTextAttributes(unselectedAttributes, for: .normal)
            viewController.tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
        }
    }
    
    // MARK: - Navigation Controllers
    
    private func createNavigationController(for viewController: UIViewController, title: String, image: UIImage?, tag: Int) -> UINavigationController {
        let tabBarItem = createTabBarItem(title: title, image: image, tag: tag)
        viewController.tabBarItem = tabBarItem
        return UINavigationController(rootViewController: viewController)
    }
    
    private func createTabBarItem(title: String, image: UIImage?, tag: Int) -> UITabBarItem {
        let resizedImage = image?.resize(to: CGSize(width: 24, height: 24))
        let tabBarItem = UITabBarItem(title: title, image: resizedImage?.withRenderingMode(.alwaysTemplate), tag: tag)
        tabBarItem.selectedImage = resizedImage?.withTintColor(.blue700, renderingMode: .alwaysOriginal)
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        return tabBarItem
    }
    
    // MARK: - Custom TabBar
    
    private class CustomTabBar: UITabBar {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            backgroundColor = .white
            layer.cornerRadius = 10
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
            layer.shadowOffset = CGSize(width: 0, height: 3)
            layer.shadowRadius = 10
            layer.shadowOpacity = 1
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard let superview = superview else { return }
            let safeAreaBottom = superview.safeAreaInsets.bottom
            var newFrame = frame
            newFrame.size.height = Constants.tabBarHeight + safeAreaBottom
            newFrame.origin.y = superview.bounds.height - newFrame.size.height
            frame = newFrame
            
            let padding: CGFloat = 15
            let tabBarItemWidth = (bounds.width - (2 * padding)) / CGFloat(items?.count ?? 1)
            var startX = padding

            for subview in subviews where subview is UIControl {
                subview.frame = CGRect(
                    x: startX,
                    y: subview.frame.origin.y,
                    width: tabBarItemWidth,
                    height: subview.frame.height
                )
                startX += tabBarItemWidth
            }
        }
    }
}
