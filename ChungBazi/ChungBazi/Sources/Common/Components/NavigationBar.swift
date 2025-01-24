//
//  NavigationBar.swift
//  ChungBazi
//
//  Created by 신호연 on 1/16/25.
//

import UIKit

extension UIViewController {
    // MARK: - Custom NavigationBar
    func addCustomNavigationBar(titleText: String?, showBackButton: Bool, showCartButton: Bool, showAlarmButton: Bool, backgroundColor: UIColor = .white) {
        
        let navigationBarView = UIView()
        navigationBarView.backgroundColor = backgroundColor
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.addSubview(navigationBarView)
        
        navigationBarView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(72)
        }
        
        let titleLabel = T20_SB(text: titleText ?? "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        
        navigationBarView.addSubview(titleLabel)
        
        if showBackButton {
            let backButton: UIButton = {
                let button = UIButton()
                button.setImage(.backIcon, for: .normal)
                button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
                return button
            }()
            navigationBarView.addSubview(backButton)
            backButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.leading.equalToSuperview().offset(28)
            }
        }
        if showCartButton {
            let cartButton: UIButton = {
                let button = UIButton()
                button.setImage(.cartIcon, for: .normal)
                button.addTarget(self, action: #selector(handleCartButtonTapped), for: .touchUpInside)
                return button
            }()
            navigationBarView.addSubview(cartButton)
            cartButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(78)
            }
        }
        if showAlarmButton {
            let alarmButton: UIButton = {
                let button = UIButton()
                button.setImage(.alarmIcon, for: .normal)
                button.addTarget(self, action: #selector(handleAlarmButtonTapped), for: .touchUpInside)
                return button
            }()
            navigationBarView.addSubview(alarmButton)
            alarmButton.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.trailing.equalToSuperview().inset(28)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(13)
        }
        
        if let navigationController = self.navigationController {
            navigationController.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
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
    
    @objc private func handleAlarmButtonTapped() {
        let alarmViewController = AlarmViewController()
        self.navigationController?.pushViewController(alarmViewController, animated: true)
    }
    
    @objc private func popViewController() {
        self.navigationController?.popViewController(animated: true)
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
