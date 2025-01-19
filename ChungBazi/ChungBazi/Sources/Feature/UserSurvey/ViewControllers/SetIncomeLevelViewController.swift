//
//  SetIncomeLevelViewController.swift
//  ChungBazi
//

import UIKit

class SetIncomeLevelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = baseSurveyView
    }
    
    private lazy var baseSurveyView = BasicSurveyView(title: "소득분위", logo: "fourthPageLogo").then {
        $0.nextBtn.setEnabled(isEnabled: true)
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetPlus), for: .touchUpInside)
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetPlus() {
        let vc = SetRegionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
