//
//  FinishLoginViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit

class FinishLoginViewController: UIViewController {
    
    var isFirst: Bool?
    
    private let finishLoginView = LogoWithTitleView(image: "heartBaro", title: "로그인 완료!\n정책을 쉽고 간편하게 확인하세요")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = finishLoginView
        goToNextView()
    }
    
    private func goToNextView() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        // 최초 로그인 시, StartSurveyViewController로
        // 그 외에는 BaseTabBarController로
        if self.isFirst ?? true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let vc = StartSurveyViewController()
                let navController = UINavigationController(rootViewController: vc)
                sceneDelegate.window?.rootViewController = navController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let vc = MainTabBarController()
                let navController = UINavigationController(rootViewController: vc)
                sceneDelegate.window?.rootViewController = navController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
