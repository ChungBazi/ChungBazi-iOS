//
//  MemberInfoEditViewController.swift
//  ChungBazi
//
//  Created by 이현주 on 1/22/26.
//

import UIKit
import SnapKit
import Then
import SwiftyToaster

class MemberInfoEditViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let memberInfoEditView = MemberInfoEditView()
    
    let userInfoData = UserInfoDataManager.shared
    let networkService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        setupUI()
        setupDelegate()
        setupActions()
        fetchUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setNavBar() {
        addCustomNavigationBar(titleText: "회원정보 수정", showBackButton: true, showCartButton: false, showAlarmButton: false, backgroundColor: .white)
        fillSafeArea(position: .top, color: .white)
    }
    
    private func setupUI() {
        view.backgroundColor = .gray50
        
        view.addSubview(scrollView)
        scrollView.addSubview(memberInfoEditView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(Constants.navigationHeight)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        memberInfoEditView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupDelegate() {
        scrollView.delegate = self
        memberInfoEditView.delegate = self
    }
    
    private func setupActions() {
        memberInfoEditView.onCompleteButtonTapped = { [weak self] in
            self?.completeButtonTapped()
        }
    }
    
    // MARK: - API Call
    private func fetchUserInfo() {
        networkService.fetchUserInfo { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let userInfo = self.convertToUserInfo(from: response)
                    
                    self.memberInfoEditView.configure(with: userInfo)
                    
                    self.validateForm()
                    
                case .failure(let error):
                    self.handleError(error, message: "사용자 정보 조회에 실패하였습니다.")
                }
            }
        }
    }
    
    private func updateUserInfo() {
        let userInfo = memberInfoEditView.getUserInfo()
        
        saveToDataManager(userInfo)
        
        let updateDto = networkService.makeUserInfoDTO(
            region: "서울시 마포구",
            employment: userInfo.employment,
            income: userInfo.income,
            education: userInfo.education,
            interests: userInfo.interests,
            additionInfo: userInfo.additionInfo)
        
        networkService.updateUserInfo(body: updateDto) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    self.handleError(error, message: "회원정보 수정에 실패하였습니다.")
                }
            }
        }
    }
    
    private func convertToUserInfo(from response: UserInfoResponseDto) -> UserInfo {
        return UserInfo(
            employment: response.employment,
            income: response.income,
            education: response.education,
            interests: response.interests,
            additionInfo: response.additions
        )
    }
    
    private func saveToDataManager(_ userInfo: UserInfo) {
        userInfoData.setEducation(userInfo.education)
        userInfoData.setEmployment(userInfo.employment)
        userInfoData.setIncome(userInfo.income)
        userInfoData.setInterests(userInfo.interests)
        userInfoData.setAdditionInfo(userInfo.additionInfo)
    }
    
    private func handleError(_ error: Error, message: String) {
        let errorMessage: String
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(_, let msg):
                errorMessage = msg
            default:
                errorMessage = error.localizedDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
         Toaster.shared.makeToast(errorMessage)
    }
    
    private func validateForm() {
        // getUserInfo()로 현재 선택된 값 확인
        let userInfo = memberInfoEditView.getUserInfo()
        
        let hasEducation = !userInfo.education.isEmpty
        let hasEmployment = !userInfo.employment.isEmpty
        let hasIncome = !userInfo.income.isEmpty
        let hasInterest = !userInfo.interests.isEmpty
        let hasAdditionInfo = !userInfo.additionInfo.isEmpty
        
        let isValid = hasEducation && hasEmployment && hasIncome && hasInterest && hasAdditionInfo
        memberInfoEditView.setCompleteButtonEnabled(isValid)
    }
    
    private func completeButtonTapped() {
        updateUserInfo()
    }
}

extension MemberInfoEditViewController: MemberInfoEditViewDelegate {
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectEducation item: String) {
        validateForm()
    }
    
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectEmployment item: String) {
        validateForm()
    }
    
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectIncome item: String) {
        validateForm()
    }
    
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectAdditionalInfo items: [String]) {
        validateForm()
    }
    
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectInterests items: [String]) {
        validateForm()
    }
}

extension MemberInfoEditViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
        if scrollView.contentOffset.y > maxOffsetY {
            scrollView.contentOffset.y = maxOffsetY
        }
    }
}
