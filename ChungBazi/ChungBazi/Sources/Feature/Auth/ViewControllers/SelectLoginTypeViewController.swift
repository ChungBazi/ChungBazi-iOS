//
//  SelectLoginTypeViewController.swift
//  ChungBazi
//

import UIKit
import KakaoSDKUser
import FirebaseAuth
import Moya
import SwiftyToaster

class SelectLoginTypeViewController: UIViewController {

    // MARK: - ViewModels / Services
    lazy var kakaoAuthVM: KakaoAuthVM = KakaoAuthVM()
    let networkService = AuthService()
    var hasNickName: Bool?
    var isFirst: Bool?
    private var lastLoginEmail: String?
    
    lazy var appleAuthVM: AppleAuthVM = {
        let vm = AppleAuthVM()
        vm.onLoginSuccess = { [weak self] hasNickName, isFirst, email in
            self?.hasNickName = hasNickName
            self?.isFirst = isFirst
            self?.lastLoginEmail = email
            self?.goToNextView()
        }
        vm.onLoginFailure = { errorMessage in
            DispatchQueue.main.async { Toaster.shared.makeToast("로그인을 실패하였습니다. 다시 시도해주세요.") }
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
                guard let name = user?.kakaoAccount?.profile?.nickname else { return }
                guard let email = user?.kakaoAccount?.email else { return }
                let fcmToken = AuthManager.shared.fcmToken ?? ""
                self.lastLoginEmail = email
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
                guard let response = response else { return }
                
                let loginType = LoginType.from(serverType: response.loginType)
                
                AuthManager.shared.saveLoginData(
                    hashedUserId: response.hashedUserId,
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    expiresIn: response.accessExp,
                    loginType: loginType,
                    isFirst: response.isFirst,
                    userName: response.userName
                )
                
                self.hasNickName = AuthManager.shared.hasNickname
                self.isFirst = response.isFirst
                self.goToNextView()
                
            case .failure(let error):
                print("카카오 서버 로그인 실패: \(error.localizedDescription)")
                DispatchQueue.main.async { Toaster.shared.makeToast("로그인에 실패했습니다. 다시 시도해 주세요.") }
            }
        }
    }

    @objc private func signUpTapped() {
        // 회원가입 화면으로 이동
        let vc = SignupViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func emailLoginTapped() {
        // 이메일 로그인 화면으로 이동
        let loginVC = EmailRegisterViewController(initialEmail: nil, signupEntry: false)
        navigationController?.pushViewController(loginVC, animated: true)
    }

    func goToNextView() {
        if hasNickName == false {
            let vc = NicknameRegisterViewController(email: lastLoginEmail, fromLogin: true)
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true, completion: nil)
            }
            return
        }
        
        
        let vc = FinishLoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
}
