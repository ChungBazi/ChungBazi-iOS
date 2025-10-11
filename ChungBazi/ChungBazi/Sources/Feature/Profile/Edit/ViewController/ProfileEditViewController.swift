//
//  ProfileEditViewController.swift
//  ChungBazi
//
//  Created by 신호연 on 1/25/25.
//

import UIKit
import SwiftyToaster

final class ProfileEditViewController: UIViewController, ProfileEditViewDelegate, CharacterEditDelegate {
    
    private let scrollView = UIScrollView()
    private let profileEditView = ProfileEditView()
    var profileData: ProfileModel
    var onProfileUpdated: ((ProfileModel) -> Void)?
    
    let networkService = UserService()
    let userInfoData = UserProfileDataManager.shared
    
    init(profileData: ProfileModel) {
        self.profileData = profileData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomNavigationBar(titleText: "프로필 설정", showBackButton: true, showCartButton: false, showAlarmButton: false)
        setupUI()
        enableKeyboardHandling(for: scrollView)
        profileEditView.delegate = self
        profileEditView.nickNameTextField.delegate = self
        profileEditView.configure(with: profileData)
        fillSafeArea(position: .top, color: .white)
        profileEditView.resetPwdButton.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
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
        addCustomNavigationBar(titleText: "", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        scrollView.showsVerticalScrollIndicator = false
        
        profileEditView.settingCharacterBtn.addTarget(self, action: #selector(settingCharacterBtnTapped), for: .touchUpInside)
        
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
    
    @objc private func settingCharacterBtnTapped() {
        let vc = CharacterEditViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapResetPassword() {
        let vc = ResetPasswordViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didCompleteEditing(nickname: String, selectedImage: String) {
        let updateProfileDto = networkService.makeUserProfileDTO(name: nickname, characterImg: selectedImage)
        networkService.updateProfile(body: updateProfileDto) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                userInfoData.setNickname(nickname)
                userInfoData.setCharacter(selectedImage)
                
                self.profileData.name = nickname
                self.profileData.characterImg = selectedImage
                self.onProfileUpdated?(self.profileData)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                let errorMessage: String
                switch error {
                case .serverError(_, let message):
                    errorMessage = "\(message)"
                default:
                    errorMessage = error.localizedDescription
                }
                DispatchQueue.main.async {
                    Toaster.shared.makeToast(errorMessage)
                }
            }
        }
    }
    
    func didSelectCharacter(characterImage: String) {
        profileEditView.updateProfileImage(characterImage: characterImage)
    }
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            let placeholderText = "닉네임은 최대 10자까지 입력 가능합니다"
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [
                    .foregroundColor: UIColor.gray300,
                    .font: UIFont.ptdMediumFont(ofSize: 16)
                ]
            )
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let defaultPlaceholder = "닉네임을 입력하세요"
        textField.attributedPlaceholder = NSAttributedString(
            string: defaultPlaceholder,
            attributes: [
                .foregroundColor: UIColor.gray300,
                .font: UIFont.ptdMediumFont(ofSize: 16)
            ]
        )
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 최대 10자까지만 입력 가능하도록 제한
        let maxLength = 10
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return newText.count <= maxLength
    }
}
