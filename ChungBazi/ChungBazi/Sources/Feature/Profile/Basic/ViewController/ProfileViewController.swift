//
//  ProfileViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit

class ProfileViewController: UIViewController, ProfileViewDelegate {

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
    
    func didTapEditProfile() {
        let vc = ProfileEditViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
