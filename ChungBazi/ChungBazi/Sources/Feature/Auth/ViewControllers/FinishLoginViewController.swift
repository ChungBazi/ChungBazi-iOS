//
//  FinishLoginViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class FinishLoginViewController: UIViewController {
    
    private let finishLoginView = LogoWithTitleView(image: "heartBaro", title: "로그인 완료!\n정책을 쉽고 간편하게 확인하세요")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = finishLoginView
        goToNextView()
    }
    
    private func goToNextView() {
        // 최초 로그인 시, StartSurveyViewController로
        // 그 외에는 BaseTabBarController로
        if AuthManager.shared.isFirstLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let termsOfServiceVC = StartSurveyViewController()
                let navigationController = UINavigationController(rootViewController: termsOfServiceVC)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
