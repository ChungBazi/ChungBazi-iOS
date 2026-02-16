//
//  FinishLoginViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class FinishLoginViewController: UIViewController {
    
    private let finishLoginView = LogoWithTitleView(image: .heartBaro, title: "로그인이 완료되었습니다!\n정책을 한눈에 살펴보세요!")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .blue700
        setupLayout()
        goToNextView()
    }
    
    private func setupLayout() {
        view.addSubview(finishLoginView)
        
        finishLoginView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func goToNextView() {
        // 최초 로그인 시, StartSurveyViewController로
        // 그 외에는 BaseTabBarController로
        if AuthManager.shared.isFirstLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                let termsOfServiceVC = StartSurveyViewController()
                let navigationController = UINavigationController(rootViewController: termsOfServiceVC)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                let termsOfServiceVC = MainTabBarController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = termsOfServiceVC
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                }
            }
        }
    }
}
