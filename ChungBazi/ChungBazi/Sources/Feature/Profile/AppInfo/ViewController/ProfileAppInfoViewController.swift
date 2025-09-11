//
//  ProfileAppInfoViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/1/25.
//

import UIKit

final class ProfileAppInfoViewController: UIViewController, ProfileAppInfoViewDelegate {
    
    private let profileAppInfoView = ProfileAppInfoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileAppInfoView.delegate = self
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
        addCustomNavigationBar(titleText: "앱 정보", showBackButton: true, showCartButton: false, showAlarmButton: false)
        view.addSubview(profileAppInfoView)
        profileAppInfoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func didSelectMenuItem(title: String, content: String) {
        let termsVC = TermsNConditionsViewController()
        termsVC.titleName = title
        termsVC.changeContents(content)
        navigationController?.pushViewController(termsVC, animated: true)
    }
}
