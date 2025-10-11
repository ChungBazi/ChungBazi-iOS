//
//  FinishRegisterViewController.swift
//  ChungBazi
//
//  Created by 엄민서 on 9/30/25.
//

import UIKit

class FinishRegisterViewController: UIViewController {
    
    var isFirst: Bool?
    
    private let finishRegisterView = LogoWithTitleView(image: "heartBaro", title: "회원가입이 완료되었습니다!\n이제 청바지에 로그인해보세요!")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = finishRegisterView
        goToNextView()
    }
    
    // TODO: - 수정 필요 
    private func goToNextView() {
        // 최초 로그인 시, StartSurveyViewController로
        // 그 외에는 BaseTabBarController로
        if self.isFirst ?? true {
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
