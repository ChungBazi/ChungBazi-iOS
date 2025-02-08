//
//  SearchViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit

final class CommunitySearchViewController: UIViewController {
    
    private let commuintySearchView = CommunitySearchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        view.addSubview(commuintySearchView)
        commuintySearchView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Constants.tabBarHeight)
            $0.leading.trailing.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: true)
    }
}
