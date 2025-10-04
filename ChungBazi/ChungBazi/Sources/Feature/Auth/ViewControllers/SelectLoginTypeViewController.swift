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
import AuthenticationServices

class SelectLoginTypeViewController: UIViewController {

    // MARK: - ViewModels / Services
    lazy var kakaoAuthVM: KakaoAuthVM = KakaoAuthVM()
    let networkService = AuthService()
    var isFirst: Bool?
    lazy var appleAuthVM: AppleAuthVM = {
        let vm = AppleAuthVM()
        vm.onLoginSuccess = { [weak self] isFirst in
            self?.isFirst = isFirst
            self?.goToNextView()
        }
        vm.onLoginFailure = { errorMessage in
            DispatchQueue.main.async { Toaster.shared.makeToast("Apple 로그인 실패: \(errorMessage)") }
        }
        return vm
    }()
    
    private lazy var selectLoginView = SelectLoginView().then {
        $0.kakaoBtn.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
        $0.appleBtn.addTarget(self, action: #selector(appleBtnTapped), for: .touchUpInside)
        $0.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        $0.emailLoginButton.addTarget(self, action: #selector(emailLoginTapped), for: .touchUpInside)
    }

    // MARK: - Lifecycle
    override func loadView() {
        view = selectLoginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue700
    }

    // MARK: - Actions
    @objc private func appleBtnTapped() {
        appleAuthVM.startLogin()
    }
    
    @objc private func kakaoLogin() {
        UIView.animate(withDuration: 0.1, animations: {
            self.selectLoginView.kakaoBtn.alpha = 0.6
            self.selectLoginView.kakaoBtn.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.selectLoginView.kakaoBtn.alpha = 1.0
                self.selectLoginView.kakaoBtn.transform = .identity
            }
        }

        kakaoAuthVM.kakaoLogin { [weak self] success in
            guard let self = self, success else { return }
            UserApi.shared.me { (user, error) in
                if let error = error {
                    DispatchQueue.main.async { Toaster.shared.makeToast("사용자 정보 가져오기 실패") }
                    print("카카오 사용자 조회 실패: \(error.localizedDescription)")
                    return
                }
                guard let name = user?.kakaoAccount?.profile?.nickname else { print("userName nil"); return }
                guard let email = user?.kakaoAccount?.email else { print("userEmail nil"); return }
                guard let fcmToken = KeychainSwift().get("FCMToken") else { print("FCMToken nil"); return }
                self.kakaoLoginProceed(name, email: email, fcmToken: fcmToken)
            }
        }
    }
    
    private func kakaoLoginProceed(_ name: String, email: String, fcmToken: String) {
        let dto = networkService.makeKakaoDTO(name: name, email: email, fcmToken: fcmToken)
        networkService.kakaoLogin(data: dto) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                KeychainSwift().set(response.refreshToken, forKey: "serverRefreshToken")
                KeychainSwift().set(response.accessToken, forKey: "serverAccessToken")
                let exp = Int(Date().timeIntervalSince1970) + response.accessExp
                KeychainSwift().set(String(exp), forKey: "serverAccessTokenExp")
                KeychainSwift().set(String(response.isFirst), forKey: "isFirst")
                self.isFirst = response.isFirst
                self.goToNextView()
            case .failure(let error):
                print("카카오 서버 로그인 실패: \(error.localizedDescription)")
            }
        }
    }

    @objc private func signUpTapped() {
        // 이메일 회원가입 화면으로 이동
        let vc = SignupViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func emailLoginTapped() {
        // 분리된 이메일 로그인 화면으로 이동 (필요 시 구현된 VC로 교체)
        let vc = EmailRegisterViewController() // 프로젝트에 맞는 구현체 사용
        navigationController?.pushViewController(vc, animated: true)
    }

    func goToNextView() {
        let vc = FinishLoginViewController()
        vc.isFirst = self.isFirst
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}
