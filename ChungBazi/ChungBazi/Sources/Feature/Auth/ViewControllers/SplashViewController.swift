//
//  SplashViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/16/25.
//

import UIKit
import Then

class SplashViewController: UIViewController {
    
    let networkService = AuthService.shared
    
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
        
        checkRemoteConfig()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.splashLabel.text = "청바지"
            self.splashLabel.font = UIFont.afgRegularFont(ofSize: 28)
        }
    }
    
    private func checkRemoteConfig() {
        RemoteConfigManager.shared.fetchConfig { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let message = RemoteConfigManager.shared.getServerCheckMessage()
                // 서버 점검 체크
                if RemoteConfigManager.shared.isServerCheck() {
                    self.showCustomAlert(title: message, buttonText: "확인") {
                        exit(0)
                    }
                    return
                }
                
                // 버전 체크
                if RemoteConfigManager.shared.isUpdateRequired() {
                    self.showCustomAlert(title: "새로운 버전이 출시되었어요!\n더 안정적인 서비스 이용을 위해 청바지를 업데이트해 주세요.", buttonText: "업데이트") {
                        self.openAppStore()
                    }
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.checkAuthenticationStatus()
                }
            }
        }
    }
    
    private func openAppStore() {
        let appStoreURL = Config.appStoreURL
        
        if let url = URL(string: appStoreURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func checkAuthenticationStatus() {
        guard AuthManager.shared.isUserLoggedIn() else {
            navigateToLoginScreen()
            return
        }

        if AuthManager.shared.isAccessTokenExpired() {
            refreshTokenAndProceed()
        } else {
            proceedToNextScreen()
        }
    }
    
    private func refreshTokenAndProceed() {
        networkService.reIssueAccesToken { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.proceedToNextScreen()
                } else {
                    // 재발급 실패 시 로그인 데이터 정리
                    AuthManager.shared.clearAuthDataForLogout()
                    self.navigateToLoginScreen()
                }
            }
        }
    }
    
    private func proceedToNextScreen() {
        if let userId = AuthManager.shared.hashedUserId {
            AmplitudeManager.shared.setUserId(userId)
        }
        
        let hasNickName = AuthManager.shared.hasNickname
        let isFirst = AuthManager.shared.isFirstLaunch
        
        if !hasNickName || isFirst {
            navigateToLoginScreen()
            return
        }
        
        navigateToMainScreen()
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
        let loginVC = SelectLoginTypeViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}
