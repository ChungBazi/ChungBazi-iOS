//
//  ProfileEditViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit

final class ProfileEditViewController: UIViewController, ProfileEditViewDelegate {
    
    private let scrollView = UIScrollView()
    private let profileEditView = ProfileEditView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        enableKeyboardHandling(for: scrollView)
        profileEditView.delegate = self
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
    

    func didCompleteEditing(nickname: String) {
        sendNicknameToServer(nickname) { [weak self] success in
            
            // FIXME: 실제 실패 시 예외 처리 필요
            guard success else {
                print("닉네임 전송 실패")
                return
            }
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.tabBarController?.selectedIndex = 3
            }
        }
    }

    private func sendNicknameToServer(_ nickname: String, completion: @escaping (Bool) -> Void) {
        // FIXME: 실제 서버 코드로 변경 필요
        completion(true)
    }
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
