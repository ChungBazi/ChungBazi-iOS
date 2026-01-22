//
//  MemberInfoEditView.swift
//  ChungBazi
//
//  Created by 이현주 on 1/22/26.
//

import UIKit

protocol MemberInfoEditViewDelegate: AnyObject {
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectEducation item: String)
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectEmployment item: String)
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectIncome item: String)
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectAdditionalInfo items: [String])
    func memberInfoEditView(_ view: MemberInfoEditView, didSelectInterests items: [String])
}

class MemberInfoEditView: UIView {
    
    weak var delegate: MemberInfoEditViewDelegate?
    
    private let contentView = UIView()
    
    private lazy var educationView = InfoDropdownSelectView(
        title: "학력",
        placeholder: "대학교 재학",
        items: Constants.eduDropDownItems, isLong: true
    )
    
    private lazy var employmentView = InfoDropdownSelectView(
        title: "취업상태",
        placeholder: "미취업자",
        items: Constants.employmentDropDownItems, isLong: true
    )
    
    private lazy var additionalInfoView = InfoMultiSelectView(
        title: "추가사항",
        items: Constants.plusCheckMenu
    )
    
    private lazy var incomeView = InfoDropdownSelectView(
        title: "소득분위",
        placeholder: "5분위",
        items: Constants.incomeDropDownItems, isLong: false
    )
    
    private lazy var interestView = InfoMultiSelectView(
        title: "관심 있는 분야",
        items: Constants.interestCheckMenu
    )
    
    private let completeBtn = CustomActiveButton(title: "회원정보 수정 완료", isEnabled: true)
    
    var onCompleteButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .gray50
        
        addSubview(contentView)
        contentView.addSubviews(
            educationView,
            employmentView,
            additionalInfoView,
            incomeView,
            interestView,
            completeBtn
        )
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        incomeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        educationView.snp.makeConstraints {
            $0.top.equalTo(incomeView.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        employmentView.snp.makeConstraints {
            $0.top.equalTo(educationView.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        additionalInfoView.snp.makeConstraints {
            $0.top.equalTo(employmentView.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        interestView.snp.makeConstraints {
            $0.top.equalTo(additionalInfoView.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        completeBtn.snp.makeConstraints {
            $0.top.equalTo(interestView.snp.bottom).offset(42)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupActions() {
        completeBtn.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    private func setupInternalDelegates() {
        educationView.delegate = self
        employmentView.delegate = self
        incomeView.delegate = self
        
        additionalInfoView.onSelectionChanged = { [weak self] selectedItems in
            guard let self = self else { return }
            self.delegate?.memberInfoEditView(self, didSelectAdditionalInfo: selectedItems)
        }
        
        interestView.onSelectionChanged = { [weak self] selectedItems in
            guard let self = self else { return }
            self.delegate?.memberInfoEditView(self, didSelectInterests: selectedItems)
        }
    }
    
    @objc private func completeButtonTapped() {
        onCompleteButtonTapped?()
    }
    
    // MARK: - Public Methods
    
    func setCompleteButtonEnabled(_ isEnabled: Bool) {
        completeBtn.setEnabled(isEnabled: isEnabled)
    }
    
    func getUserInfo() -> UserInfo {
        return UserInfo(
            region: UserInfoDataManager.shared.getRegion(), // 지역은 이미 저장된 값 사용
            employment: employmentView.getSelectedItem() ?? "",
            income: incomeView.getSelectedItem() ?? "",
            education: educationView.getSelectedItem() ?? "",
            interests: interestView.getSelectedItems(),
            additionInfo: additionalInfoView.getSelectedItems()
        )
    }
    
    /// 초기 데이터 설정
    func configure(with userInfo: UserInfo) {
        // 드롭다운은 delegate를 통해 설정
        // Multi-select만 설정
        additionalInfoView.setSelected(items: userInfo.additionInfo)
        interestView.setSelected(items: userInfo.interests)
    }
}

extension MemberInfoEditView: CustomDropdownDelegate {
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        // 어떤 dropdown인지 확인하고 적절한 delegate 메서드 호출
        // 초기 데이터 설정
        if dropdown == educationView.getDropdown() {
            educationView.setSelectedItem(item)
            delegate?.memberInfoEditView(self, didSelectEducation: item)
            
        } else if dropdown == employmentView.getDropdown() {
            employmentView.setSelectedItem(item)
            delegate?.memberInfoEditView(self, didSelectEmployment: item)
            
        } else if dropdown == incomeView.getDropdown() {
            incomeView.setSelectedItem(item)
            delegate?.memberInfoEditView(self, didSelectIncome: item)
        }
    }
}
