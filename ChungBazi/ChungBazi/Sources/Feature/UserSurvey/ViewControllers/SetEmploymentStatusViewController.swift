//
//  SetEmploymentStatusViewController.swift
//  ChungBazi
//

import UIKit

class SetEmploymentStatusViewController: UIViewController {
    
    private lazy var baseSurveyView = BasicSurveyView(title: "취업상태", logo: "twicePageLogo").then {
        $0.nextBtn.setEnabled(isEnabled: true)
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetPlus), for: .touchUpInside)
    }
    
    private lazy var dropdown = CustomDropdown(title: "취업상태를 선택하세요", hasBorder: true, items: Constants.employmentDropDownItems)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
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
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetPlus() {
        let vc = SetPlusViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
