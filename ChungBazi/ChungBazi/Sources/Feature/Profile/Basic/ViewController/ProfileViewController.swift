//
//  ProfileViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SwiftyToaster
import KeychainSwift

class ProfileViewController: UIViewController {
    
    private let profileView = ProfileView()
    private var profileData: ProfileModel?
    private var rewardData: RewardModel?
    let networkService = AuthService()
    let kakaoAuthVM = KakaoAuthVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        profileView.delegate = self
        fetchData()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "프로필", showBackButton: false, showCartButton: false, showAlarmButton: true)
        view.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func fetchData() {
        // FIXME: 추후 서버 연결 시 아래 코드 제거
        profileData = ProfileModel(userId: 0, name: "hy", email: "hello@world.com", profileImg: "")
        if let profileData = profileData {
            profileView.configure(with: profileData)
        }
        rewardData = RewardModel(currentReward: 1, myPosts: 2, myComments: 3)
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
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapEditProfile() {
        navigateToEditProfile()
    }
    
    func didTapNotificationSettings() {
        navigateToNotificationSettings()
    }
    
    func didTapAppInfo() {
        navigateToAppInfo()
    }
    
    func didTapLogout() {
        showCustomAlert(
            title: "로그아웃 하시겠습니까?",
            rightButtonText: "확인",
            rightButtonAction: {
                // FIXME: 로그아웃 처리
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
                // FIXME: 탈퇴 처리
                print("탈퇴 처리")
            }
        )
    }
    
    func didTapMyRewardView() {
        guard let rewardData = rewardData else { return }
        showProfileMyRewardView(rewardData: rewardData)
    }
    
    private func logout() {
        networkService.logout() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                kakaoAuthVM.kakaoLogout()
                Toaster.shared.makeToast("로그아웃 성공")
                KeychainSwift().set("", forKey: "serverAccessToken")
                KeychainSwift().set("", forKey: "serverAccessTokenExp")
                KeychainSwift().set("", forKey: "serverRefreshToken")
                DispatchQueue.main.async {
                    self.showSplashScreen()
                }
            case .failure(_):
                Toaster.shared.makeToast("로그아웃 실패")
            }
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
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = splashViewController
        }, completion: nil)
    }
}
