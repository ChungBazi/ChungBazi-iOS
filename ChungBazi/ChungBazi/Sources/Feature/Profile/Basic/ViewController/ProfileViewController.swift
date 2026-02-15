//
//  ProfileViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SwiftyToaster

class ProfileViewController: UIViewController {
    private let profileView = ProfileView()
    private var profileData: ProfileModel?
    private var rewardData: RewardModel?
    let userInfoData = UserProfileDataManager.shared
    
    let userAuthService = UserAuthService()
    let kakaoAuthVM = KakaoAuthVM()
    private let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        profileView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfile()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "프로필", showBackButton: false, showCartButton: false, showAlarmButton: false)
        view.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func fetchProfile() {
        showLoading()
        
        userService.fetchProfile { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoading()
            }
            
            switch result {
            case .success(let response):
                self.profileData = ProfileModel(userId: response.userId, name: response.name, email: response.email, characterImg: response.characterImg)
                userInfoData.setNickname(response.name)
                userInfoData.setCharacter(response.characterImg)
                DispatchQueue.main.async {
                    if let profileData = self.profileData {
                        self.profileView.configure(with: profileData)
                    }
                }
            case .failure(let response):
                print("❌프로필 불러오기 실패: \(response.localizedDescription)")
            }
        }
    }
    
    private func navigateToEditProfile() {
        guard let profileData = profileData else { return }
        let editVC = ProfileEditViewController(profileData: profileData)
        editVC.onProfileUpdated = { [weak self] updatedProfile in
            guard let self = self else { return }
            self.profileData = updatedProfile
            self.profileView.configure(with: updatedProfile)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func navigateToNotificationSettings() {
        let vc = ProfileNotificationSettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAppInfo() {
        let vc = ProfileAppInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToEditMemberInfo() {
        let vc = MemberInfoEditViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProfileViewController: ProfileViewDelegate {
    
    func didTapEditProfile() {
        navigateToEditProfile()
    }
    
    func didTapNotificationSettings() {
        navigateToNotificationSettings()
    }
    
    func didTapEditMemberInfo() {
        navigateToEditMemberInfo()
    }
    
    func didTapContact() {
        if let url = URL(string: Config.contactFormURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func didTapAppInfo() {
        navigateToAppInfo()
    }
    
    func didTapLogout() {
        showCustomAlert(
            title: "로그아웃 하시겠습니까?",
            rightButtonText: "확인",
            rightButtonAction: {
                self.logout()
            }
        )
    }
    
    func didTapWithdraw() {
        showCustomAlert(
            headerTitle: "탈퇴 하시겠습니까?",
            title: "탈퇴한 계정 정보와 서비스\n이용기록 등은 복구할 수 없으니\n신중하게 선택하시길 바랍니다.",
            rightButtonText: "확인",
            rightButtonAction: {
                self.deleteUser()
            }
        )
    }
    
    func didTapMyRewardView() {
        guard let rewardData = rewardData else { return }
        showProfileMyRewardView(rewardData: rewardData)
    }
    
    private func logout() {
        userAuthService.logout() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.performSocialLogout {
                    AmplitudeManager.shared.setUserId(nil)
                    AmplitudeManager.shared.reset()
                    AuthManager.shared.clearAuthDataForLogout()
                    
                    DispatchQueue.main.async {
                        Toaster.shared.makeToast("로그아웃되었습니다.")
                        self.showSplashScreen()
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    Toaster.shared.makeToast("로그아웃에 실패하였습니다. 다시 시도해 주세요.")
                }
            }
        }
    }
    
    private func deleteUser() {
        userAuthService.deleteUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.performSocialWithdrawal {
                    AmplitudeManager.shared.setUserId(nil)
                    AmplitudeManager.shared.reset()
                    AuthManager.shared.clearAuthDataForWithdrawal()
                    
                    DispatchQueue.main.async {
                        Toaster.shared.makeToast("회원탈퇴가 완료되었습니다.")
                        self.showSplashScreen()
                    }
                }
            case .failure(_):
                DispatchQueue.main.async {
                    Toaster.shared.makeToast("회원탈퇴에 실패하였습니다. 다시 시도해 주세요.")
                }
            }
        }
    }
    
    private func performSocialLogout(completion: @escaping () -> Void) {
        guard let loginType = AuthManager.shared.loginType else {
            completion()
            return
        }
        
        switch loginType {
        case .kakao:
            kakaoAuthVM.kakaoLogout { success in
                completion()
            }
            
        case .apple:
            completion()
            
        case .normal:
            completion()
        }
    }

    private func performSocialWithdrawal(completion: @escaping () -> Void) {
        guard let loginType = AuthManager.shared.loginType else {
            completion()
            return
        }
        
        switch loginType {
        case .kakao:
            kakaoAuthVM.unlinkKakaoAccount { success in
                completion()
            }
            
        case .apple:
            completion()
            
        case .normal:
            completion()
        }
    }
    
    func showSplashScreen() {
        let splashViewController = SplashViewController()
        
        // 현재 윈도우 가져오기
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first else {
            print("윈도우를 가져올 수 없습니다.")
            return
        }
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
            window.rootViewController = splashViewController
        }, completion: nil)
    }
}

