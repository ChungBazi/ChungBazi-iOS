//
//  SetIncomeLevelViewController.swift
//  ChungBazi
//

import UIKit

class SetIncomeLevelViewController: UIViewController, CustomDropdownDelegate {
    
    let userInfoData = UserInfoDataManager.shared
    
    private lazy var baseSurveyView = BasicSurveyView(title: "소득분위", logo: "fourthPageLogo").then {
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetRegion), for: .touchUpInside)
    }
    
    private lazy var dropdown = CustomDropdown(height: 48, fontSize: 16, title: "분위", hasBorder: true, items: Constants.incomeDropDownItems)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        dropdown.delegate = self
        addComoponents()
        setConstraints()
    }
    
    private func addComoponents() {
        view.addSubview(baseSurveyView)
        baseSurveyView.addSubview(dropdown)
    }
    
    private func setConstraints() {
        baseSurveyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dropdown.snp.makeConstraints {
            $0.top.equalTo(baseSurveyView.title.snp.bottom).offset(48)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(118)
            $0.height.equalTo(48 * Constants.eduDropDownItems.count + 48 + 8)
        }
    }
    
    // MARK: - CustomDropdownDelegate
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        // 드롭다운에서 선택된 항목에 따라 버튼 활성화
        baseSurveyView.nextBtn.setEnabled(isEnabled: true)
        userInfoData.setIncome(item)
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetRegion() {
        userInfoData.setRegion("서울시 마포구") //데모데이용 임시데이터 (지역 설정 화면 제거용)
        let vc = SetInterestViewController() // 기존: SetRegionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
