//
//  SetEducationViewController.swift
//  ChungBazi
//

import UIKit
import Then

class SetEducationViewController: UIViewController, CustomDropdownDelegate {
    
    let userInfoData = UserInfoDataManager.shared
    
    private lazy var baseSurveyView = BasicSurveyView(title: "학력", logo: "firstPageLogo").then {
        $0.toggleBackButton()
        $0.nextBtn.addTarget(self, action: #selector(goToSetEmploymentStatus), for: .touchUpInside)
    }
    
    private lazy var dropdown = CustomDropdown(height: 48, title: "학력을 선택하세요", hasBorder: true, items: Constants.eduDropDownItems)

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
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(45)
            $0.height.equalTo(48 * Constants.eduDropDownItems.count + 48 + 8)
        }
    }
    
    // MARK: - CustomDropdownDelegate
    func dropdown(_ dropdown: CustomDropdown, didSelectItem item: String) {
        // 드롭다운에서 선택된 항목에 따라 버튼 활성화
        baseSurveyView.nextBtn.setEnabled(isEnabled: true)
        userInfoData.setEducation(item)
    }
    
    @objc private func goToSetEmploymentStatus() {
        let vc = SetEmploymentStatusViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
