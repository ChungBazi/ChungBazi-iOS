//
//  FinishSurveyViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/17/25.
//

import UIKit

class FinishSurveyViewController: UIViewController {

    private let finishSurveyView = LogoWithTitleView(image: .lightBaro, title: "알려주신 정보를 바탕으로\n정책을 추천해 드리겠습니다!")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .blue700
        setupLayout()
        goToNextView()
    }
    
    private func setupLayout() {
        view.addSubview(finishSurveyView)
        
        finishSurveyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func goToNextView() {
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
