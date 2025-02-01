//
//  SelectLoginTypeViewController.swift
//  ChungBazi
//

import UIKit
import KakaoSDKUser
import KeychainSwift
import FirebaseAuth
import Moya
import SwiftyToaster


class SelectLoginTypeViewController: UIViewController {
    
    lazy var kakaoAuthVM: KakaoAuthVM = KakaoAuthVM()
    let networkService = AuthService()
    var isFirst: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = selectLoginView
    }
    
    private lazy var selectLoginView = SelectLoginView().then {
        $0.kakaoBtn.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
    }
    
    @objc private func kakaoLogin() {
        self.kakaoAuthVM.kakaoLogin { success in
            if success {
                UserApi.shared.me { (user, error) in
                    if let error = error {
                        print("에러 발생: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            Toaster.shared.makeToast("사용자 정보 가져오기 실패")
                        }
                        return
                    }
                    
                    guard let name = user?.kakaoAccount?.profile?.nickname else {
                        print("userName이 nil입니다.")
                        return
                    }
                    guard let email = user?.kakaoAccount?.email else {
                        print("userEmail가 nil입니다.")
                        return
                    }
                    guard let fcmToken = KeychainSwift().get("FCMToken") else {
                        print("fcmToken이 없습니다.")
                        return
                    }
                    self.kakaoLoginProceed(name, email: email, fcmToken: fcmToken)
                }
            }
        }
    }
    
    private func kakaoLoginProceed(_ name: String, email: String, fcmToken: String) {
        let kakaoDTO = self.networkService.makeKakaoDTO(name: name, email: email, fcmToken: fcmToken)
        self.networkService.kakaoLogin(data: kakaoDTO) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("카카오 로그인 성공")
                KeychainSwift().set(response.refreshToken, forKey: "serverRefreshToken")
                KeychainSwift().set(response.accessToken, forKey: "serverAccessToken")
                KeychainSwift().set(String(response.accessExp), forKey: "serverAccessTokenExp")
                self.isFirst = response.isFirst
                self.goToNextView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func goToNextView() {
        let vc = FinishLoginViewController()
        vc.isFirst = self.isFirst
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}
