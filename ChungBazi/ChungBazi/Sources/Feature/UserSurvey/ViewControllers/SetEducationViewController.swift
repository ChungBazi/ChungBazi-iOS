//
//  SetEducationViewController.swift
//  ChungBazi
//

import UIKit

class SetEducationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.view = baseSurveyView
    }
    

    private let baseSurveyView = BasicSurveyView(title: "학력", logo: "firstPageLogo")

}
