//
//  FinishSurveyViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/17/25.
//

import UIKit

class FinishSurveyViewController: UIViewController {

    private let finishLoginView = LogoWithTitleView(image: "lightBaro", title: "알려주신 정보를 바탕으로\n정책을 추천해 드리겠습니다!")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = finishLoginView
        goToNextView()
    }
    
    private func goToNextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let vc = MainTabBarController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
