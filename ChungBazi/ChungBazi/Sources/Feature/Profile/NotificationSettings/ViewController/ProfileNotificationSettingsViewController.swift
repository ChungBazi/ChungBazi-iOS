//
//  ProfileNotificationSettingsViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit

final class ProfileNotificationSettingsViewController: UIViewController {
    
    private let profileNotificationSettingsView = ProfileNotificationSettingsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        addCustomNavigationBar(titleText: "알림 설정", showBackButton: true, showCartButton: false, showAlarmButton: true)
        view.addSubview(profileNotificationSettingsView)
        profileNotificationSettingsView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
}
