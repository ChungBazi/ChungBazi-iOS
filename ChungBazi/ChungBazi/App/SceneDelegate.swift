//
//  SceneDelegate.swift
//  ChungBazi
//
//  Created by 이현주 on 1/14/25.
//

import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var pendingNotificationInfo: [AnyHashable: Any]? // 알림 정보 저장
    var pendingDeepLink: URL? // 딥링크 저장
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // 앱이 알림을 통해 실행되었는지 체크
        if let notificationResponse = connectionOptions.notificationResponse {
            pendingNotificationInfo = notificationResponse.notification.request.content.userInfo
        }
        
        // 앱이 딥링크를 통해 실행되었는지 체크
        if let urlContext = connectionOptions.urlContexts.first {
            let url = urlContext.url
            if isKakaoLink(url) {
                pendingDeepLink = extractDeepLinkFromKakaoLink(url)
            } else {
                pendingDeepLink = url
            }
        }
        
        setRootViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationFromForeground(_:)), name: NSNotification.Name("NotificationReceived"), object: nil)
    }
    
    private func setRootViewController() {
        let isLoggedIn = AuthManager.shared.isUserLoggedIn()
        
        // 딥링크/알림을 통해 실행된 경우
        if pendingDeepLink != nil || pendingNotificationInfo != nil {
            if isLoggedIn {
                let mainTBC = MainTabBarController()
                let navController = UINavigationController(rootViewController: mainTBC)
                window?.rootViewController = navController
                window?.makeKeyAndVisible()
                
                // 화면 표시 후 딥링크 처리
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    if let deepLink = self?.pendingDeepLink {
                        self?.handleDeepLink(url: deepLink)
                        self?.pendingDeepLink = nil
                    } else if let userInfo = self?.pendingNotificationInfo {
                        self?.handleNotification(userInfo: userInfo)
                        self?.pendingNotificationInfo = nil
                    }
                }
                
            } else {
                // 로그인 안 되어 있을 경우 → 로그인 화면으로 이동
                let loginVC = SelectLoginTypeViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                window?.rootViewController = navController
                window?.makeKeyAndVisible()
                
                // 로그인 후 딥링크 처리를 위해 저장 유지
            }
        } else {
            // 일반 실행일 경우 → Splash 화면을 통해 네비게이션 진행
            let splashVC = SplashViewController()
            let navController = UINavigationController(rootViewController: splashVC)
            navController.isNavigationBarHidden = true
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        }
    }
    
    @objc private func handleNotificationFromForeground(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        handleNotification(userInfo: userInfo)
    }
    
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["notificationType"] as? String else { return }
        guard let topVC = UIApplication.getMostTopViewController(),
              let navigationController = topVC.navigationController ?? topVC as? UINavigationController else { return }
        
        var destinationVC: UIViewController?
        
        switch type {
        case "POLICY_ALARM":
            if let policyIdString = userInfo["policyId"] as? String, let policyId = Int(policyIdString) {
                let vc = PolicyDetailViewController()
                vc.configureEntryPoint(.alarm)
                vc.policyId = policyId
                destinationVC = vc
            }
//        case "COMMUNITY_ALARM":
//            if let postIdString = userInfo["postId"] as? String, let postId = Int(postIdString) {
//                let vc = CommunityDetailViewController(postId: postId)
//                destinationVC = vc
//            }
//        case "REWARD_ALARM":
//            let vc = MyCharacterViewController()
//            destinationVC = vc
        default:
            break
        }
        
        if let destinationVC = destinationVC {
            // 기존에 같은 타입의 VC가 있으면 제거
            cleanNavigationStack(navigationController: navigationController, keepingType: Swift.type(of: destinationVC))
            navigationController.pushViewController(destinationVC, animated: true)
        }
    }
    
    private func handleDeepLink(url: URL) {
        guard url.scheme == "chungbazi" else {
            return
        }
        
        let host = url.host
        let pathComponents = url.pathComponents
        
        guard let topVC = UIApplication.getMostTopViewController(),
              let navigationController = topVC.navigationController ?? topVC as? UINavigationController else { return }
        
        var destinationVC: UIViewController?
        
        switch host {
        case "policy":
            if pathComponents.count > 1 {
                let policyIdString = pathComponents[1]
                if let policyId = Int(policyIdString) {
                    let vc = PolicyDetailViewController()
                    vc.configureEntryPoint(.deepLink)
                    vc.policyId = policyId
                    destinationVC = vc
                }
            }
        default:
            break
        }
        
        if let destinationVC = destinationVC {
            // 기존에 같은 타입의 VC가 있으면 제거
            cleanNavigationStack(navigationController: navigationController, keepingType: type(of: destinationVC))
            navigationController.pushViewController(destinationVC, animated: true)
        }
    }
    
    // 네비게이션 스택 정리
    private func cleanNavigationStack(navigationController: UINavigationController, keepingType: UIViewController.Type) {
        var viewControllers = navigationController.viewControllers
        viewControllers.removeAll { type(of: $0) == keepingType }
        navigationController.viewControllers = viewControllers
    }
    
    private func isKakaoLink(_ url: URL) -> Bool {
        return (url.scheme?.hasPrefix("kakao") == true) && (url.host == "kakaolink")
    }

    private func handleKakaoLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        if let deepLinkString = queryItems.first(where: { $0.name == "url" })?.value,
           let decoded = deepLinkString.removingPercentEncoding,
           let deepLinkURL = URL(string: decoded) {

            if deepLinkURL.scheme == "chungbazi" {
                handleDeepLink(url: deepLinkURL)
            }
        }
    }
    
    private func extractDeepLinkFromKakaoLink(_ url: URL) -> URL? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let deepLinkString = queryItems.first(where: { $0.name == "url" })?.value,
              let decoded = deepLinkString.removingPercentEncoding,
              let deepLinkURL = URL(string: decoded) else { return nil }

        return deepLinkURL
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
                return
            }
            
            if isKakaoLink(url) {
                handleKakaoLink(url)
                return
            }
            
            if url.scheme == "chungbazi" {
                handleDeepLink(url: url)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            AmplitudeManager.shared.trackAppOpen()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // 현재 화면 자동 추적
            let currentScreen = UIViewController.getCurrentViewController()?.screenName ?? "unknown"
            
            AmplitudeManager.shared.trackAppExit(
                lastScreen: currentScreen
            )
        }
    }
}
