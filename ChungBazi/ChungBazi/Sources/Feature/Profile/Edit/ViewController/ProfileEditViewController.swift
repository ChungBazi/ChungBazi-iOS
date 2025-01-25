//
//  ProfileEditViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit

final class ProfileEditViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let profileEditView = ProfileEditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        enableKeyboardHandling(for: scrollView)
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
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: false)
        
        view.addSubview(scrollView)
        scrollView.addSubview(profileEditView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Constants.navigationHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        profileEditView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
    }
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
