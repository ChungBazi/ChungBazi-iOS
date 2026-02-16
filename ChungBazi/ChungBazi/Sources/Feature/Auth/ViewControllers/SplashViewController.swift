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
    
    private var isCheckingConfig = false
    private var shouldShowUpdateAlert = false
    private var shouldShowServerCheckAlert = false
    private var serverCheckMessage: String = ""
    
    private let splashLabel = UILabel().then {
        $0.text = "정책도 쉽고 간편하게"
        $0.textColor = .white
        $0.font = UIFont.ptdSemiBoldFont(ofSize: 28)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 앱스토어에서 돌아왔을 때 alert 재표시
        if shouldShowServerCheckAlert {
            showServerCheckAlert()
        } else if shouldShowUpdateAlert {
            showUpdateRequiredAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
        addComponents()
        setConstraints()
        updateLabelText()
        
        // 현재 뷰 컨트롤러가 내비게이션 컨트롤러 안에 있는지 확인
        if self.navigationController == nil {
            let navController = UINavigationController(rootViewController: self)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
        
        // 앱 재진입 감지
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        checkRemoteConfig()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 앱 재진입 시 RemoteConfig 재체크
    @objc private func appWillEnterForeground() {
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
    
    // MARK: - RemoteConfig Check
    
    private func checkRemoteConfig() {
        // 중복 체크 방지
        guard !isCheckingConfig else { return }
        
        isCheckingConfig = true
        
        RemoteConfigManager.shared.fetchConfig { [weak self] success in
            guard let self = self else { return }
            
            self.isCheckingConfig = false
            
            DispatchQueue.main.async {
                // fetch 실패 시, 기본 플로우로 진행
                guard success else {
                    self.proceedWithDefaultFlow()
                    return
                }
            
                self.serverCheckMessage = RemoteConfigManager.shared.getServerCheckMessage()
                
                // 서버 점검 체크
                if RemoteConfigManager.shared.isServerCheck() {
                    self.shouldShowServerCheckAlert = true
                    self.shouldShowUpdateAlert = false
                    self.showServerCheckAlert()
                    return
                }
                
                // 버전 체크
                if RemoteConfigManager.shared.isUpdateRequired() {
                    self.shouldShowUpdateAlert = true
                    self.shouldShowServerCheckAlert = false
                    self.showUpdateRequiredAlert()
                    return
                }
                
                // 모든 체크 통과
                self.shouldShowServerCheckAlert = false
                self.shouldShowUpdateAlert = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.checkAuthenticationStatus()
                }
            }
        }
    }
    
    /// RemoteConfig fetch 실패 시 기본 플로우로 진행
    private func proceedWithDefaultFlow() {
        shouldShowServerCheckAlert = false
        shouldShowUpdateAlert = false
        
        // fetch 실패 시에도 앱은 정상 동작하도록 진행
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkAuthenticationStatus()
        }
    }
    
    // MARK: - Alert
    
    private func showServerCheckAlert() {
        // 중복 alert 방지
        if presentedViewController != nil {
            return
        }
        
        showCustomAlert(title: serverCheckMessage, buttonText: "확인") {
            exit(0)
        }
    }
    
    private func showUpdateRequiredAlert() {
        // 중복 alert 방지
        if presentedViewController != nil {
            return
        }
        
        showCustomAlert(
            title: "새로운 버전이 출시되었어요!\n더 안정적인 서비스 이용을 위해 청바지를 업데이트해 주세요.",
            buttonText: "업데이트"
        ) {
            self.openAppStore()
        }
    }
    
    private func openAppStore() {
        let appStoreURL = Config.appStoreURL
        
        if let url = URL(string: appStoreURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Authentication Check
    
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
    
    // MARK: - Navigation
    
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























