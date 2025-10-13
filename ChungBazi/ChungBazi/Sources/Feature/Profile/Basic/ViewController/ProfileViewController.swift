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
    let userInfoData = UserProfileDataManager.shared
    
    let networkService = AuthService()
    let kakaoAuthVM = KakaoAuthVM()
    private let service = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        profileView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfile()
        fetchReward()
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
        
        service.fetchProfile { [weak self] result in
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
    
    private func fetchReward() {
        showLoading()
        
        service.fetchReward { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoading()
            }
            
            switch result {
            case .success(let response):
                self.rewardData = RewardModel(currentReward: response.rewardLevel, myPosts: response.postCount, myComments: response.commentCount)
            case .failure(let error):
                print(error)
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
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapMyCharacterView() {
        let vc = MyCharacterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
//                self.kakaoAuthVM.unlinkKakaoAccount { success in
//                    if success {
//                        Toaster.shared.makeToast("회원탈퇴 성공")
//                        self.clearForQuit()
//                        DispatchQueue.main.async {
//                            self.showSplashScreen()
//                        }
//                    } else {
//                        Toaster.shared.makeToast("회원탈퇴 실패")
//                    }
//                }
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
                self.clearForQuit()
                DispatchQueue.main.async {
                    self.showSplashScreen()
                }
            case .failure(_):
                Toaster.shared.makeToast("로그아웃 실패")
            }
        }
    }
    
    private func deleteUser() {
        networkService.deleteUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                kakaoAuthVM.unlinkKakaoAccount { success in
                    if success {
                        Toaster.shared.makeToast("회원탈퇴 성공")
                        self.clearForQuit()
                        DispatchQueue.main.async {
                            self.showSplashScreen()
                        }
                    } else {
//                        Toaster.shared.makeToast("회원탈퇴 실패")
                    }
                }
            case .failure(_):
                Toaster.shared.makeToast("회원탈퇴 실패")
            }
        }
    }
    
    func clearForQuit() {
        ["serverAccessToken", "serverAccessTokenExp", "serverRefreshToken"].forEach {
            KeychainSwift().delete($0)
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

