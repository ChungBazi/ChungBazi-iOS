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
    
    var pendingNotificationInfo: [AnyHashable: Any]? // 🔔 알림 정보 저장
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        // 🔥 앱이 알림을 통해 실행되었는지 체크
        if let notificationResponse = connectionOptions.notificationResponse {
            pendingNotificationInfo = notificationResponse.notification.request.content.userInfo
        }
        
        setRootViewController()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationFromForeground(_:)), name: NSNotification.Name("NotificationReceived"), object: nil)
    }
    
    private func setRootViewController() {
        let isLoggedIn = AuthManager.shared.isUserLoggedIn()
        
        if let userInfo = pendingNotificationInfo {
            // 🔔 알림을 통해 실행되었을 경우
            if isLoggedIn {
                let mainTBC = MainTabBarController()
                let navController = UINavigationController(rootViewController: mainTBC)
                window?.rootViewController = navController
                window?.makeKeyAndVisible()
            } else {
                // ❌ 로그인 안 되어 있을 경우 → 로그인 화면으로 이동
                let loginVC = SelectLoginTypeViewController()
                window?.rootViewController = loginVC
                window?.makeKeyAndVisible()
            }
        } else {
            // 🏠 일반 실행일 경우 → Splash 화면을 통해 네비게이션 진행
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
                vc.policyId = policyId
                destinationVC = vc
            }
        case "COMMUNITY_ALARM":
            if let postIdString = userInfo["postId"] as? String, let postId = Int(postIdString) {
                let vc = CommunityDetailViewController(postId: postId)
                destinationVC = vc
            }
        case "REWARD_ALARM":
            let vc = MyCharacterViewController()
            destinationVC = vc
        default:
            break
        }
        
        if let destinationVC = destinationVC {
            navigationController.pushViewController(destinationVC, animated: true)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
