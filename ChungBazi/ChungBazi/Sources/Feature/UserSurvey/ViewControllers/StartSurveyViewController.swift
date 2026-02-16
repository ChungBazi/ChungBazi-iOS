//
//  StartSurveyViewController.swift
//  ChungBazi
//

import UIKit
import SnapKit
import Then

class StartSurveyViewController: UIViewController {

    private let startSurveyView = LogoWithTitleView(image: .questionBaro, title: "더 정확한 추천을 위해\n몇 가지 정보를 알려주세요!")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        setConstraints()
        goToNext()
    }
    
    private func setConstraints() {
        view.addSubview(startSurveyView)
        
        startSurveyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func goToNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
            let termsOfServiceVC = SetEducationViewController()
            let navigationController = UINavigationController(rootViewController: termsOfServiceVC)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navigationController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}
