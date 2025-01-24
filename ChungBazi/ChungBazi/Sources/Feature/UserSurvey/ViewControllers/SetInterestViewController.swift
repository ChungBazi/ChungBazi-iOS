//
//  SetInterestViewController.swift
//  ChungBazi
//

import UIKit

class SetInterestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = baseSurveyView
    }

    private lazy var baseSurveyView = BasicSurveyView(title: "관심 있는 분야를\n선택해주세요", logo: "sixthPageLogo").then {
        $0.nextBtn.setEnabled(isEnabled: true)
        $0.backBtn.addTarget(self, action: #selector(goToback), for: .touchUpInside)
        $0.nextBtn.addTarget(self, action: #selector(goToSetPlus), for: .touchUpInside)
    }
    
    @objc private func goToback() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func goToSetPlus() {
        let vc = FinishSurveyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
