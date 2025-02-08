//
//  ProfileViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let profileView = ProfileView()
    private var profileData: ProfileModel?
    private var rewardData: RewardModel?
    private let service = UserService()
    
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
        service.fetchProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileData = ProfileModel(userId: profile.userId, name: profile.name, email: profile.email, characterImg: profile.characterImg)
                DispatchQueue.main.async {
                    if let profileData = self.profileData {
                        self.profileView.configure(with: profileData)
                    }
                }
            case .failure(let error):
                print("❌프로필 불러오기 실패: \(error.localizedDescription)")
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
                print("로그아웃 처리")
            }
        )
    }
    
    func didTapWithdraw() {
        showCustomAlert(
            title: "탈퇴 하시겠습니까?\n\n탈퇴한 계정 정보와 서비스\n이용기록 등은 복구할 수 없으니\n신중하게 선택하시길 바랍니다.",
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
}
