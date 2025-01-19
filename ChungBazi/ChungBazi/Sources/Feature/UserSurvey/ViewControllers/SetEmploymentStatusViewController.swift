//
//  SetEmploymentStatusViewController.swift
//  ChungBazi
//

import UIKit

class SetEmploymentStatusViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = baseSurveyView
    }
    
    private lazy var baseSurveyView = BasicSurveyView(title: "취업상태", logo: "twicePageLogo").then {
        $0.nextBtn.setEnabled(isEnabled: true)
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetPlus), for: .touchUpInside)
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetPlus() {
        let vc = SetPlusViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
