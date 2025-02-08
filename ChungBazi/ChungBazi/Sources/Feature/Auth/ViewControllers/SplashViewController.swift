//
//  SplashViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit
import Then
import KeychainSwift


class SplashViewController: UIViewController {
    
    let networkService = AuthService()
    
    private let splashLabel = UILabel().then {
        $0.text = "정책도 쉽고 간편하게"
        $0.textColor = .white
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 28)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        addComponents()
        setConstraints()
        updateLabelText()
        
        // 현재 뷰 컨트롤러가 내비게이션 컨트롤러 안에 있는지 확인
        if self.navigationController == nil {
            // 네비게이션 컨트롤러가 없으면 새로 설정
            let navController = UINavigationController(rootViewController: self)
            navController.modalPresentationStyle = .fullScreen
            
            // 현재 창의 rootViewController 교체
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkAuthenticationStatus()
        }
    }
    
    private func addComponents() {
        view.addSubview(splashLabel)
    }
    
    private func setConstraints() {
        splashLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func updateLabelText() {
        // 1초 후 텍스트 업데이트
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.splashLabel.text = "청바지"
            self.splashLabel.font = UIFont.afgRegularFont(ofSize: 28)
        }
    }
    
    func checkAuthenticationStatus() {
        guard let expirationString = KeychainSwift().get("serverAccessTokenExp"),
              let expirationTimestamp = Int(expirationString) else {
            DispatchQueue.main.async {
                self.navigateToLoginScreen()
            }
            return
        }

        let expirationDate = Date(timeIntervalSince1970: TimeInterval(expirationTimestamp))

        if Date() < expirationDate {
            print("토큰이 아직 유효함")
            checkIsFirst()
        } else {
            print("토큰이 만료됨 → 재발급 시도")
            networkService.reIssueAccesToken { success in
                if success {
                    self.checkIsFirst()
                } else {
                    DispatchQueue.main.async {
                        self.navigateToLoginScreen()
                    }
                }
            }
        }
    }
    
    private func checkIsFirst() {
        guard let isFirstString = KeychainSwift().get("isFirst") else { return }
        let isFirst = Bool(isFirstString)
        if isFirst == true || isFirst == nil {
            navigateToSurveyScreen()
        } else { navigateToMainScreen() }
    }
    
    private func navigateToMainScreen() {
        let mainTabBarController = MainTabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func navigateToLoginScreen() {
        let vc = SelectLoginTypeViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func navigateToSurveyScreen() {
        let vc = StartSurveyViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navigationController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
