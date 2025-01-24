//
//  SetEducationViewController.swift
//  ChungBazi
//

import UIKit
import Then

class SetEducationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = baseSurveyView
    }
    
    private lazy var baseSurveyView = BasicSurveyView(title: "학력", logo: "firstPageLogo").then {
        $0.toggleBackButton()
        $0.nextBtn.setEnabled(isEnabled: true)
        $0.nextBtn.addTarget(self, action: #selector(goToSetEmploymentStatus), for: .touchUpInside)
    }
    
    @objc private func goToSetEmploymentStatus() {
        let vc = SetEmploymentStatusViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
