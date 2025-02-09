//
//  NavigationBar.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit
import Then

extension UIViewController {
    // MARK: - Custom NavigationBar

    func addCustomNavigationBar(titleText: String?, tintColor: UIColor = .black, showBackButton: Bool, showCartButton: Bool, showAlarmButton: Bool, showHomeRecommendTabs: Bool = false, activeTab: Int = 0, showRightCartButton: Bool = false, showLeftSearchButton: Bool = false, backgroundColor: UIColor = .clear) {
  
        let navigationBarView = UIView()
        navigationBarView.backgroundColor = backgroundColor
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.addSubview(navigationBarView)
        
        navigationBarView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constants.navigationHeight)
        }
        
        let titleLabel = T20_SB(text: titleText ?? "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = tintColor
        
        navigationBarView.addSubview(titleLabel)
        
        if showBackButton {
            let backButton = UIButton().then {
                let backIcon = UIImage(resource: .backIcon).withRenderingMode(.alwaysTemplate)
                $0.setImage(backIcon, for: .normal)
                $0.tintColor = tintColor
                $0.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(backButton)
            backButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.leading.equalToSuperview().offset(28)
            }
        }
        if showCartButton {
            let cartButton = UIButton().then {
                let cartIcon = UIImage(resource: .cartIcon).withRenderingMode(.alwaysTemplate)
                $0.setImage(cartIcon, for: .normal)
                $0.tintColor = tintColor
                $0.addTarget(self, action: #selector(handleCartButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(cartButton)
            cartButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(78)
            }
        }
        if showAlarmButton {
            let alarmButton = UIButton().then {
                let alarmIcon = UIImage(resource: .alarmIcon).withRenderingMode(.alwaysTemplate)
                $0.setImage(alarmIcon, for: .normal)
                $0.tintColor = tintColor
                $0.addTarget(self, action: #selector(handleAlarmButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(alarmButton)
            alarmButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(28)
            }
        }
        if showRightCartButton {
            let alarmButton = UIButton().then {
                let cartIcon = UIImage(resource: .cartIcon).withRenderingMode(.alwaysTemplate)
                $0.setImage(cartIcon, for: .normal)
                $0.tintColor = tintColor
                $0.addTarget(self, action: #selector(handleCartButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(alarmButton)
            alarmButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(28)
            }
        }
        if showLeftSearchButton {
            let searchButton = UIButton().then {
                let searchIcon = UIImage(resource: .searchIcon).withRenderingMode(.alwaysTemplate) 
                $0.setImage(searchIcon, for: .normal)
                $0.tintColor = .gray800
                $0.addTarget(self, action: #selector(handleSearchButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(searchButton)
            searchButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(78)
            }
        }
        
        if showShareButton {
            let shareButton = UIButton().then {
                $0.setImage(UIImage(named: "share_icon"), for: .normal)
                $0.addTarget(self, action: #selector(handleShareButtonTapped), for: .touchUpInside)
            }
            navigationBarView.addSubview(shareButton)
            shareButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(28)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(28)
        }
        
        if let navigationController = self.navigationController {
            navigationController.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
        
        if showHomeRecommendTabs {
            addHomeRecommendTabs(to: navigationBarView, activeTab: activeTab)
        }
    }
    // MARK: - Home-Recommend Tabs
    private func addHomeRecommendTabs(to navigationBarView: UIView, activeTab: Int) {
        let homeButton = UIButton(type: .system)
        homeButton.setTitle("홈", for: .normal)
        homeButton.titleLabel?.font = UIFont(name: AppFontName.pSemiBold, size: 28)
        homeButton.setTitleColor(activeTab == 0 ? .black : AppColor.gray300, for: .normal)
        homeButton.tag = 0
        homeButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        let recommendButton = UIButton(type: .system)
        recommendButton.setTitle("추천", for: .normal)
        recommendButton.titleLabel?.font = UIFont(name: AppFontName.pSemiBold, size: 28)
        recommendButton.setTitleColor(activeTab == 1 ? .black : AppColor.gray300, for: .normal)
        recommendButton.tag = 1
        recommendButton.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [homeButton, recommendButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.alignment = .center
        navigationBarView.addSubview(buttonStackView)

        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().offset(30)
        }
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if !(self is HomeViewController) {
                self.navigationController?.popToRootViewController(animated: false)
            }
        case 1:
            if !(self is RecommendViewController) {
                let recommendVC = RecommendViewController()
                self.navigationController?.pushViewController(recommendVC, animated: false)
            }
        default:
            break
        }
    }
    
    // MARK: - Button Handlers with Effects
    @objc private func handleBackButtonTapped() {
        triggerCustomTransition(type: .push, direction: .fromLeft)
        popViewController()
    }
    
    @objc private func handleCartButtonTapped() {
        let cartViewController = CartViewController()
        self.navigationController?.pushViewController(cartViewController, animated: true)
    }
    
    @objc private func handleSearchButtonTapped() {
        let searchViewController = CommunitySearchViewController()
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    @objc private func handleAlarmButtonTapped() {
        let alarmViewController = AlarmViewController()
        self.navigationController?.pushViewController(alarmViewController, animated: true)
    }
    
    @objc private func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleShareButtonTapped() {
        let shareText = ""
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Custom TransitionEffects
    private func triggerCustomTransition(type: CATransitionType, direction: CATransitionSubtype?) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = type
        transition.subtype = direction
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
    }
}
