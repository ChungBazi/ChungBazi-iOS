//
//  ProfileViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit

class ProfileViewController: UIViewController {

    private let profileView = ProfileView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        profileView.delegate = self
    }
    
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "프로필", showBackButton: false, showCartButton: false, showAlarmButton: false)
        view.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.tabBarHeight)
            $0.leading.trailing.equalToSuperview()
        }
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func didTapEditProfile() {
        let vc = ProfileEditViewController()
        navigationController?.pushViewController(vc, animated: true)
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
        showProfileMyRewardView()
    }
}
