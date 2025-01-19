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
        self.view = finishLoginView
        goToNextView()
    }
    
    private func goToNextView() {
        // 최초 로그인 시, StartSurveyViewController로
        // 그 외에는 BaseTabBarController로
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let vc = StartSurveyViewController()
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }
}
