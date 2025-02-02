//
//  CommunityViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 2/2/25.
//

import UIKit

final class CommunityViewController: UIViewController, CommunityViewDelegate {
    
    private let communityView = CommunityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        view.addSubview(communityView)
        communityView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        addCustomNavigationBar(titleText: "커뮤니티", showBackButton: false, showCartButton: false, showAlarmButton: true, showLeftSearchButton: true)
    }
    
    private func fetchData() {
        
    }
    
    func didTapWriteButton() {
        let nextVC = CommunityWriteViewController()
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
